#!/bin/bash

# To run this script, do 
# qsub -t 1-n ssubmit_filterpass_Vardict.sh CONFIG IDS
#
#$ -N pass_Vardict
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

## This script will select passed variants, normalise small variants called by Vardict

## 1) Select passed variants

$BCFTOOLS view -Ov -o $VARDICT_DIR/${PATIENT_ID}${TYPE}-vardict.vcf $VARDICT_DIR/${PATIENT_ID}${TYPE}-vardict.vcf.gz
$BCFTOOLS view -f PASS $VARDICT_DIR/${PATIENT_ID}${TYPE}-vardict.vcf > $VARDICT_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-vardict.passed.filtered.vcf

## 2) Normalise variants

$BCFTOOLS norm \
   -f $REFERENCE \
   --check-ref we \
   -m-both \
   $VARDICT_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-vardict.passed.filtered.vcf | \
   $BCFTOOLS sort \
   -Oz \
   -o $VARDICT_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-vardict.normalised.passed.filtered.vcf.gz

$BCFTOOLS index -t $VARDICT_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-vardict.normalised.passed.filtered.vcf.gz

rm $VARDICT_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-vardict.passed.filtered.vcf
rm $VARDICT_DIR/${PATIENT_ID}${TYPE}-vardict.vcf





