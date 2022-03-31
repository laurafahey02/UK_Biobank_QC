#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
library(dplyr)
sqc_ID <- read.table(args[1], header=T)
sqc_1 <- sqc_ID %>% select(IID,genotyping.array,Submitted.Gender,PC1:PC8)
write.table(sqc_1, args[2], quote=F, row.names=F)
