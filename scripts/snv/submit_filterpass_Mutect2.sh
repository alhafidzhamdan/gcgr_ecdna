#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_filterpass_Mutect2.sh CONFIG IDS
#
#$ -N pass_M2
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

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG
BCFTOOLS=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/snakemake/bin/bcftools

## This script will select passed variants, normalise small variants called by Mutect2

## 1) Select passed M2 variants

$BCFTOOLS view -Ov -o $M2_VARIANTS_FILTERED/${PATIENT_ID}T-filtered.vcf $M2_VARIANTS_FILTERED/${PATIENT_ID}T-filtered.vcf.gz
$BCFTOOLS view -f PASS $M2_VARIANTS_FILTERED/${PATIENT_ID}T-filtered.vcf > $M2_VARIANTS_PASSED/${PATIENT_ID}T-passed.filtered.vcf

## 2) Normalise M2 variants

$BCFTOOLS norm \
   -f $REFERENCE \
   --check-ref we \
   -m-both \
   $M2_VARIANTS_PASSED/${PATIENT_ID}T-passed.filtered.vcf | \
   $BCFTOOLS sort \
   -Oz \
   -o $M2_VARIANTS_PASSED/${PATIENT_ID}T-Mutect2.normalised.passed.filtered.vcf.gz

$BCFTOOLS index -t $M2_VARIANTS_PASSED/${PATIENT_ID}T-Mutect2.normalised.passed.filtered.vcf.gz

rm $M2_VARIANTS_PASSED/${PATIENT_ID}T-passed.filtered.vcf
rm $M2_VARIANTS_FILTERED/${PATIENT_ID}T-filtered.vcf

## 3) Decompose insertions into further SNPs
#
#vt decompose_blocksub \
#    -o $M2_VARIANTS_PASSED/${PATIENT_ID}-vtdecompblocksub.normalised.passed.filtered.vcf.gz \
#    $M2_VARIANTS_PASSED/${PATIENT_ID}-normalised.passed.filtered.vcf.gz
#    
#vt index $M2_VARIANTS_PASSED/${PATIENT_ID}-vtdecompblocksub.normalised.passed.filtered.vcf.gz




