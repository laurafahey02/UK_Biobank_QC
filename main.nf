#!/usr/bin/env nextflow

params.pfiles = "/data/UKB/Genotypes/Imputed/*.{pgen,pvar,psam}"
params.sqc_file = "/data/UKB/Genotype_QC/qc-files/ukb_sqc_v2.txt"
params.sqc_header = "/data/UKB/Genotype_QC/qc-files/sqc_headers"
params.fam_file = "/data/UKB/Genotype_QC/qc-files/ukb23739_cal_chr1_v2_s488250.fam"                                                                                                                                                   
params.rel_file = "/data/UKB/Genotype_QC/qc-files/ukb23739_rel_s488250.dat"
params.IDsPheno = "/data/UKB/Genotype_QC/qc-files/IDs_to_keep.txt"
params.covar = "/data/UKB/Genotype_QC/qc-files/ukb23448.tab"
params.eur_samples = "/data/UKB/Genotype_QC/qc-files/euro_samples8.txt"
params.mfi_files = "/data/UKB/Genotype_QC/mfi-files/*.mfi"
params.retractedconsent = "/data/lfahey/qc-files/retracted_consent210820.txt"

params.outdir = "/data/UKB/Genotype_QC/QCd_files"
params.maf = 0.01
params.geno = 0.02
params.hwe = 1e-8

geno=params.geno
maf=params.maf
hwe=params.hwe

pfiles_ch = Channel.fromFilePairs(params.pfiles, size:3)
mfi_ch = Channel
                .fromPath(params.mfi_files)
                .map { file -> tuple(file.baseName, file) }

println """\

         U K B - Q C - P I P E L I N E
         ======================================
         Starting files       : ${params.pfiles}
         outdir               : ${params.outdir}

         """
         .stripIndent()

process Format_sqc_file {
   
    //Aim: Add sample IDs to ukb_sqc_v2.txt to create the file sample_qc.txt. Samples are in the same order in fam files and ukb_sqc_v2.txt.
    
    input:
    path 'sqc_file' from params.sqc_file
    path 'sqc_header' from params.sqc_header
    path 'fam_file' from params.fam_file

    output:
    path 'sqc_id.txt' into sqc

    script:

    """
    Rscript "/data/UKB/Genotype_QC/bin/sqc.R" $sqc_file $sqc_header $fam_file sqc_id.txt
    """
}

process Create_list_samples_to_exclude {

    input:
    path sqc_id from sqc

    output:
    path 'samples_to_remove.txt' into sqc_extract

    script:

    """
    Rscript "/data/UKB/Genotype_QC/bin/sqc_extract.R" $sqc_id samples_to_remove.txt
    """
}

process Create_list_related_samples {

    input:
    path rel_file from params.rel_file
    path IDs2Keep from params.IDsPheno

    output:
    path 'rel_to_remove.txt' into final_rel

    script:

    """
    awk '{print \$1}' $rel_file | sed "1d" > rel_ids1.txt
    awk '{print \$2}' $rel_file | sed "1d" > rel_ids2.txt
    cat rel_ids1.txt rel_ids2.txt | sort | uniq -c | sort -nr > rel_ids_count.txt    
    Rscript "/data/UKB/Genotype_QC/bin/count_rel.R" rel_ids_count.txt excess_rel.txt
    python "/data/UKB/Genotype_QC/bin/rel.py" $rel_file excess_rel.txt $IDs2Keep extract.txt
    cat extract.txt excess_rel.txt | awk '{print \$1, \$1}' > rel_to_remove.txt
    """
}

process SNPs_info_thresholding {

    input:
    tuple val(chr_number), file(mfi_files) from mfi_ch

    output:
    tuple val(chr_number), file("${chr_number}.passInfo") into infoPass

    script:

    """
    Rscript "/data/UKB/Genotype_QC/bin/snps_to_keep.R" $mfi_files ${chr_number}.passInfo
    """
}

process makeCovar {

    input:
    path sqc_id from sqc
    path covar_file from params.covar

    output:
    path 'all_covar.txt' into covar_ch

    script:

    """
    Rscript "/data/UKB/Genotype_QC/bin/sqc_covar.R" $sqc_id sqc_covar
    awk 'FNR==NR{a[\$1]=\$0;next} (\$1 in a) {print \$1,a[\$1],\$2,\$3,\$4}' sqc_covar $covar_file > all_covar.txt
    sed -i 's/UKBB/1/g; s/UKBL/2/g; s/M/1/g; s/F/2/g' all_covar.txt
    """
}

process samples_to_remove {

    input:
    path samples_to_remove from sqc_extract
    path rel_to_remove from final_rel
    path retracted_consent from params.retractedconsent

    output:
    path 'all_samples_to_remove.txt' into all_samples_to_remove

    script:

    """
    cat $samples_to_remove $rel_to_remove $retracted_consent | sort | uniq | sed '/^-/d' > all_samples_to_remove.txt
    """
}


process Plink_QC {
    publishDir "$params.outdir"
    tag "$chr_number"

    input:
    tuple val(chr_number), file(pfiles), file(snps) from pfiles_ch.join(infoPass)
    path all_samples_to_remove from all_samples_to_remove
    path eur_samples from params.eur_samples

    output:
    path "${chr_number}_qcd.p*" into output

    script:

    """
    plink2 --pgen ${pfiles[0]} --psam ${pfiles[1]} --pvar ${pfiles[2]} --extract $snps --keep $eur_samples --remove $all_samples_to_remove --geno ${geno} --maf ${maf} --hwe ${hwe} --make-pgen --out ${chr_number}_qcd
    """
}

process Plink_covar {
    publishDir "$params.outdir"

    input:
    path pfiles from output.first()
    path all_covar from covar_ch

    output:
    path 'plink2.cov' into covar1

    script:

    """
    plink2 --pgen ${pfiles[0]} --psam ${pfiles[1]} --pvar ${pfiles[2]} --covar $all_covar --write-covar
    """
}

