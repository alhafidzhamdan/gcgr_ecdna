#!/bin/bash

# To run this script, do 
# qsub -t n submit_subset_germline_vcfs.sh
#
#$ -N subset_germline
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 16
#$ -l h_rt=250:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

IDS=$1
STAGE=$2

## Define files/directories
PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

## Subset germline VCFs to include only genes of interest
GERMLINE_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/germline/${STAGE}

cd $GERMLINE_DIR

echo "Subsetting germline VCFs to key genes..."
zcat ${PATIENT_ID}.germline.snpeff.vcf.gz | grep -vsi "##" | grep -E 'TP53|BRCA1|BRCA2|MLH1|MSH2|MSH6|ATM|AXIN2|BRIP1|CHEK2|CDKN2A|DICER2|EGFR|FLCN|NF1|PALB2|PMS2|PTEN|RAD51C|RAD51D|PMS2|RB1|RET|SDHB|VHL' > ${PATIENT_ID}.pathological.germline.snpeff.txt











