#!/bin/bash

eval "$(micromamba shell hook --shell bash)"
micromamba activate ldsc

# Read data iteratively from the CSV file
tail -n +2 ../data/UKBB_GWAS_sumstats_teste.csv | while IFS=',' read -r _ TRAIT _ _ _ _ NAME _; do

  # Download trait
  wget "https://broad-ukb-sumstats-us-east-1.s3.amazonaws.com/round2/additive-tsvs/$NAME";
  
  # Unzip and rename sumstats
  mv "$NAME" "${TRAIT}_sumstats.tsv.bgz"
  gunzip -c "${TRAIT}_sumstats.tsv.bgz" > "${TRAIT}_sumstats.tsv"

  # Run formatting script
  export SUMSTATS_FILE="${TRAIT}_sumstats.tsv"
  export OUTPUT_FILE="${TRAIT}_sumstats_ldsc.tsv"
  Rscript ../r/ldsc_sumstats_setup.R

  cd ../ldsc

  # Run LDSC munge
  ./munge_sumstats.py \
  --sumstats "../data/${TRAIT}_sumstats_ldsc.tsv" \
  --merge-alleles w_hm3.snplist \
  --out "${TRAIT}" \
  --chunksize 500000;

  # Run LDSC
  ./ldsc.py --rg "dep.sumstats.gz,${TRAIT}.sumstats.gz" \
  --ref-ld-chr eur_w_ld_chr/ \
  --w-ld-chr 1000G_weights/1000G_Phase3_weights_hm3_no_MHC/ \
  --out "${TRAIT}_dep"

  wait
  cd ../bash

  # Delete sumstats file
  rm "${TRAIT}_sumstats.tsv" "${TRAIT}_sumstats_ldsc.tsv"

done

