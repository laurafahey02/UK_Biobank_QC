# UK_Biobank_QC
nextflow run main.nf -bg -with-trace

Arguments:

--IDsPheno  &emsp; &nbsp; list of sample IDs, one ID per line, with phenotype information (preferentially keep when filtering by relatedness)<br/>
--covar  &emsp; &emsp; &ensp; &nbsp; .tab output &ensp;from ukbconv (phenotype related covariates)<br/>
--outdir  &emsp; &emsp; &emsp; output directory path

Optional arguments:

--maf &emsp; &emsp; &emsp; Minor allele frequency cutoff<br/>
--geno &emsp; &emsp; &nbsp; Missingness per marker cutoff<br/>
--hwe &emsp; &emsp; &ensp; &nbsp; Hardy-Weinberg equilibrium cutoff<br/>
