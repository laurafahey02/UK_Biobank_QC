### Input files ###
# ukb_chr1.fam (Obtained using: ./ukbgene cal -c1 -m; fam files are the same for all chromosomes)
# ukb_sqc_v2.txt (downloaded through EGA)
# Aim: add sample IDs to ukb_sqc_v2.txt to create the file sample_qc.txt. Samples are in the same order in fam files and ukb_sqc_v2.txt.

#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
library(dplyr)
sqc <- read.table(args[1])
sqc <- sqc[,3:ncol(sqc)] # removes first 2 columns
# add header
sqc_headers <- readLines(args[2])
colnames(sqc) <- sqc_headers
fam <- read.table(args[3])
FID <- fam$V1
IID <- fam$V2
sqc_ID <- cbind.data.frame(FID,IID,sqc)
write.table(sqc_ID, args[4], quote = FALSE, row.names = FALSE)
