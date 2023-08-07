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

## Annotate ssvs
java -Xmx4G -jar $SNPEFF_JAR -i vcf -o vcf GRCh38.99 $ENSEMBLE_VCF > $PURPLE_SNV_INPUT && bgzip $PURPLE_SNV_INPUT 




