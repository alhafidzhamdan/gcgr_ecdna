#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_filterpass_Strelka2.sh CONFIG IDS
#
#$ -N pass_S2
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 2
#$ -l h_rt=12:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
IDS=$2
STAGE=$3
TYPE=$4

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG


BCFTOOLS=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/snakemake/bin/bcftools

## This script will select passed variants, normalise small variants called by Strelka2

## 1) Select passed variants

$BCFTOOLS view -Ov -o $STRELKA2_DIR/${PATIENT_ID}${TYPE}-strelka2.vcf $STRELKA2_DIR/${PATIENT_ID}${TYPE}-strelka2.vcf.gz
$BCFTOOLS view -f PASS $STRELKA2_DIR/${PATIENT_ID}${TYPE}-strelka2.vcf > $S2_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-strelka2.passed.filtered.vcf

## 2) Normalise variants

$BCFTOOLS norm \
   -f $REFERENCE \
   --check-ref we \
   -m-both \
   $S2_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-strelka2.passed.filtered.vcf | \
   $BCFTOOLS sort \
   -Oz \
   -o $S2_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-strelka2.normalised.passed.filtered.vcf.gz

$BCFTOOLS index -t $S2_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-strelka2.normalised.passed.filtered.vcf.gz

rm $S2_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-strelka2.passed.filtered.vcf
rm $STRELKA2_DIR/${PATIENT_ID}${TYPE}-strelka2.vcf

## 3) Decompose insertions into further SNPs

#vt decompose_blocksub \
#    -o $S2_VARIANTS_PASSED/${PATIENT_ID}-strelka2.vtdecompblocksub.normalised.passed.filtered.vcf.gz \
#    $S2_VARIANTS_PASSED/${PATIENT_ID}-strelka2.normalised.passed.filtered.vcf.gz
#   
#vt index $S2_VARIANTS_PASSED/${PATIENT_ID}-strelka2.vtdecompblocksub.normalised.passed.filtered.vcf.gz




