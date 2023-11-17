# Link to depression and neuroticism respectively. wget it and change
# the name to "depression_sumstats.tsv" and "neuroticism_sumstats.txt"
# http://ftp.ebi.ac.uk/pub/databases/gwas/summary_statistics/GCST005001-GCST006000/GCST005902/harmonised/29662059-GCST005902-EFO_0003761-build37.f.tsv.gz
# http://ftp.ebi.ac.uk/pub/databases/gwas/summary_statistics/GCST006001-GCST007000/GCST006476/sumstats_neuroticism_ctg_format.txt.gz

library(vroom)

# Format depression data
dep <- vroom("depression_sumstats.tsv")
dep_ldsc <- subset(neur, select = c("variant_id", "chromosome", "effect_allele", "other_allele", "N", "p_value", "beta"))
colnames(dep_ldsc) <- c("SNP", "CHR", "A1", "A2", "N", "P", "BETA")
vroom_write(dep_ldsc, "depression_sumstats_ldsc.txt")

# Format neuroticism data
neur <- vroom("neuroticism_sumstats.txt")
neur_ldsc <- subset(neur, select = c("variant_id", "chromosome", "effect_allele", "other_allele", "N", "p_value", "beta"))
colnames(neur_ldsc) <- c("SNP", "CHR", "A1", "A2", "N", "P", "BETA")
vroom_write(neur_ldsc, "neuroticism_sumstats_ldsc.txt")