#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
library(dplyr)
sqc_ID <- read.table(args[1], header=T)
het_miss_outliers <- sqc_ID$FID[sqc_ID$het.missing.outliers == 1]
discordant_sex <- sqc_ID$FID[sqc_ID$Submitted.Gender != sqc_ID$Inferred.Gender]
sex_aneuploidy <- sqc_ID$FID[sqc_ID$putative.sex.chromosome.aneuploidy == 1]
samples_to_remove <- c(het_miss_outliers, discordant_sex, sex_aneuploidy)
samples_to_remove <- unique(samples_to_remove)
samples_to_remove <- data.frame(samples_to_remove, samples_to_remove)
write.table(samples_to_remove, args[2], quote = FALSE, row.names = FALSE, col.names=FALSE)
