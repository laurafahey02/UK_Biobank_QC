#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# Use UK Biobank supplied mfi files to create a list of SNPs for each chromosome with info score > 0.8.
mfi_chr <- read.table(args[1], header = F)
snpsTokeep <- mfi_chr[mfi_chr$V8 > 0.8,]
write.table(snpsTokeep$V2, args[2], quote=FALSE, row.names=FALSE, col.names=FALSE)
