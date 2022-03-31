#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

rel_count <- read.table(args[1])
excess_rel <- rel_count[rel_count$V1 > 15,]
write(excess_rel$V2, args[2], sep="\n")
