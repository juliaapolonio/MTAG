library(vroom)
library(dplyr)
setwd("~/scripts/bash/")

# Get file names from command line arguments or environment variables
sumstats_file <- ifelse(length(Sys.getenv("SUMSTATS_FILE")) > 0, Sys.getenv("SUMSTATS_FILE"), "test_sumstats.tsv")

variants_file <- "variants.tsv"


# Read data from files
sumstats <- vroom(sumstats_file, col_select = c("variant", "beta", "se", "pval", "n_complete_samples"))
ref <- vroom(variants_file, col_select = c("variant" ,"rsid", "chr", "ref", "alt"))

# Perform the join and selection
ldsc <- sumstats %>%
  inner_join(ref, by = "variant") %>%
  dplyr::select(SNP=rsid, CHR=chr, A1=ref, A2=alt, P=pval, BETA=beta, N=n_complete_samples)

# Write the result to a file
output_file <- ifelse(length(commandArgs(trailingOnly = TRUE)) >= 3,
                      commandArgs(trailingOnly = TRUE)[3],
                      ifelse(length(Sys.getenv("OUTPUT_FILE")) > 0, Sys.getenv("OUTPUT_FILE"), "test_sumstats_ldsc.tsv"))

vroom_write(ldsc, output_file)