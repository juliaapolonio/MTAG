# Clone and install LDSC
git clone https://github.com/bulik/ldsc.git
cd ldsc
git checkout b02f2a6
conda env create --file environment.yml
source activate ldsc

# Get european reference files
wget https://zenodo.org/records/7768714/files/1000G_Phase3_baselineLD_v2.2_ldscores.tgz
tar -xvzf 1000G_Phase3_baselineLD_v2.2_ldscores.tgz
mkdir eur_w_ld_chr
mv baselineLD* eur_w_ld_chr

# Get snp list
wget https://ibg.colorado.edu/cdrom2021/Day06-nivard/GenomicSEM_practical/eur_w_ld_chr/w_hm3.snplist

# Munge sumstats files. File must contain only "SNP","A1","A2","N","P","BETA or OR or Z". Should use this exact header notation
./munge_sumstats.py \
--sumstats ../data/neuroticism_sumstats_ldsc.txt \
--N 170911 \
--merge-alleles w_hm3.snplist \
--out neur \
--chunksize 500000

# Munge sumstats files
./munge_sumstats.py \
--sumstats ../data/depression_sumstats_ldsc.txt \
--N 322580 \
--merge-alleles w_hm3.snplist \
--out dep \
--chunksize 500000

# Rename files according to LDSC format
cd eur_w_ld_chr/
for file in baselineLD.*; do
  # Extract the number part from the file name using a regular expression
  if [[ $file =~ baselineLD\.([0-9]+)\.(.*) ]]; then
    number="${BASH_REMATCH[1]}"
    rest_of_filename="${BASH_REMATCH[2]}"
    # Rename the file, keeping the rest of the filename intact
    new_filename="${number}.${rest_of_filename}"
    mv "$file" "$new_filename"
  fi
done

# Download, decompress and format weights folder
cd ../
mkdir 1000G_weights
cd 1000G_weights
wget https://zenodo.org/records/7768714/files/1000G_Phase3_weights_hm3_no_MHC.tgz
tar -xvzf 1000G_Phase3_weights_hm3_no_MHC.tgz
cd 1000G_Phase3_weights_hm3_no_MHC
for file in weights.hm3_noMHC.*.l2.ldscore.gz; do
  # Extract the number part from the file name
  number=$(echo "$file" | sed -n 's/weights\.hm3_noMHC\.\([0-9]\+\)\.l2.ldscore.gz/\1/p')
  # Rename the file
  mv "$file" "${number}.l2.ldscore.gz"
done

# Run LDSC 
cd ../../
./ldsc.py --rg dep.sumstats.gz,neur.sumstats.gz --ref-ld-chr eur_w_ld_chr/ --w-ld-chr 1000G_weights/1000G_Phase3_weights_hm3_no_MHC/ --out neur_depd