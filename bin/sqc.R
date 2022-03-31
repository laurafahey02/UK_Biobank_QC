#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
library(dplyr)
sqc <- read.table(args[1])
sqc <- sqc[,3:ncol(sqc)] # removes first 2 columns
# add header
sqc_headers <- readLines(args[2])
colnames(sqc) <- sqc_headers
fam <- read.table(args[3]) # all fam files the same
FID <- fam$V1
IID <- fam$V2
sqc_ID <- cbind.data.frame(FID,IID,sqc)
write.table(sqc_ID, args[4], quote = FALSE, row.names = FALSE)
