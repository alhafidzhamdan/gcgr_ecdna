#!/bin/bash

## This script uses annovar helper function to annotate small variants with CADD, SIFT, polyphen, GERP etc scores.

# qsub -t n submit_annovar.sh IDS
#
#$ -N annovar
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 4
#$ -l h_rt=10:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

## Define files/directories
## IDS are sample names and full paths to VCFs
## TYPE is optional, depending on the file format

IDS=$1
OUTPUT_DIR=$2
TYPE=$3

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1 | cut -f 1`
VCF=`head -n $SGE_TASK_ID $IDS | tail -n 1 | cut -f 2`
SAMPLE_ID=${PATIENT_ID}${TYPE}

ANNOVAR_DIR=/exports/igmm/eddie/Glioblastoma-WGS/scripts/annovar

cd $ANNOVAR_DIR

## Download the annotation reference set (done once)
## ./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar dbnsfp42a humandb/

## Step 1: Convert VCF object into annovar friendly format
##./convert2annovar.pl -format vcf4 $VCF > ${SAMPLE_ID}.annovar.input

## Step 2: Annotate with different scores as above
##./table_annovar.pl ${SAMPLE_ID}.annovar.input humandb/ -protocol dbnsfp42a -operation f -build hg38 -nastring . -out ${OUTPUT_DIR}/${SAMPLE_ID}
./table_annovar.pl $VCF humandb/ -buildver hg38 -out ${OUTPUT_DIR}/${SAMPLE_ID} -remove -protocol refGene,cytoBand,dbnsfp42a -operation g,r,f -nastring . -vcfinput


### For germline variants, subset to key genes only
##cd ${OUTPUT_DIR}
##cat ${SAMPLE_ID}.hg38_multianno.txt | grep -E 'TP53|BRCA1|BRCA2|MLH1|MSH2|MSH6|ATM|AXIN2|BRIP1|CHEK2|CDKN2A|DICER2|EGFR|FLCN|NF1|PALB2|PMS2|PTEN|RAD51C|RAD51D|PMS2|RB1|RET|SDHB|VHL' | grep exonic | cat multianno_header.txt -  > ${SAMPLE_ID}.multianno_subset.germline.txt



















