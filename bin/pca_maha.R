# This script calculates the multi-mean eigenvectors of CEU samples and measures the distance of each UKB sample to this mean. Samples with Mahalanobis distance < 6 s.d are identified as being of european ancestry.
# Necessary files:
#    CEU_PCs1-8.txt (output of pca.sh)
#    UKB_PCs1-8.txt (output of pca.sh)

euro_pca <- read.table("CEU_PCs1-8.txt",header=FALSE)
ukb_pca <- read.table("UKB_PCs1-8.txt",header=FALSE, row.names = 1)
matrix_ukb_pca <- data.matrix(ukb_pca, rownames.force = TRUE)
multi_mean <- sapply(euro_pca,mean)
cov_ukb = cov(matrix_ukb_pca)
ml <- mahalanobis(matrix_ukb_pca, multi_mean, cov_ukb, method = mcd)
ml_df_sorted <- data.frame(sort(ml, decreasing = TRUE))
euro <- ml_df_sorted[ml_df_sorted$sort.ml..decreasing...TRUE. < 6,,drop=FALSE]
non_euro <- ml_df_sorted[ml_df_sorted$sort.ml..decreasing...TRUE. >= 6,,drop=FALSE]
euro_samples <- rownames(euro)
noneuro_samples <- rownames(non_euro)
writeLines(euro_samples, "euro_samples", sep = "\n")
writeLines(noneuro_samples, "noneuro_samples", sep = "\n")
