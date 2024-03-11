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