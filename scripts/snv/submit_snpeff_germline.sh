#!/bin/bash
#
#$ -N snpeff_germline
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=8G
#$ -pe sharedmem 8
#$ -l h_rt=72:00:00

##Define SGE parameters

CONFIG=$1
IDS=$2
STAGE=$3

##Define files/paths
PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG

RAW_GERMLINE_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/bcbio/${STAGE}
RAW_GERMLINE=${RAW_GERMLINE_DIR}/${PATIENT_ID}/*/*gatk*.gz
ANNOTATED_GERMLINE_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/germline/${STAGE}
ANNOTATED_GERMLINE=${ANNOTATED_GERMLINE_DIR}/${PATIENT_ID}.germline.snpeff.vcf

## Annotate ssvs
java -Xmx4G -jar $SNPEFF_JAR -i vcf -o vcf GRCh38.99 $RAW_GERMLINE > $ANNOTATED_GERMLINE
bgzip $ANNOTATED_GERMLINE 




