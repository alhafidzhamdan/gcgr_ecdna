#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_gridss_somatic_filter.sh CONFIG IDS BATCH
#
#$ -N filtGRIDSS
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -l h_rt=36:00:00

##### Superceded by GRIPSS #####

IDS=$1
BATCH=$2

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

GRIDSS_SOMATIC_FILTER=/exports/igmm/eddie/Glioblastoma-WGS/scripts/gridss/scripts/gridss_somatic_filter.R
GRIDSS_PON=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/gridss/pondir
HG38_BSGENOME='BSgenome.Hsapiens.UCSC.hg38'
GRIDSS_OUTPUT=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/gridss/results
GRIDSS_RAW=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/gridss/results/${PATIENT_ID}T2.gridss.raw.vcf.gz
##GRIDSS_TEST=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/gridss/results/${PATIENT_ID}.gridss.raw.test.vcf.gz
GRIDSS_FILTERED=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/gridss/results/${PATIENT_ID}T2.gridss.filtered.vcf.gz
GRIDSS_PLOT_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/gridss/plotdir
LIBGRIDSS=/exports/igmm/eddie/Glioblastoma-WGS/scripts/gridss/scripts

##### Need tidyverse, readr, stringr, VariantAnnotation, StructuralVariantAnnotation, stringdist packages pre-installed.
##### Need R 3.6 or above

export PATH=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/r_env/bin:$PATH


if [ ! -f $GRIDSS_FILTERED ]
then
echo "Running somatic filter for ${PATIENT_ID}"

Rscript $GRIDSS_SOMATIC_FILTER \
 --pondir $GRIDSS_PON/${BATCH} \
 --ref $HG38_BSGENOME \
 --input $GRIDSS_RAW \
 --output $GRIDSS_FILTERED \
 --scriptdir $LIBGRIDSS

fi    

##mv $GRIDSS_OUTPUT/${PATIENT_ID}.gridss.filtered.vcf.bgz $GRIDSS_OUTPUT/${PATIENT_ID}.gridss.filtered.vcf.gz
##tabix -p vcf $GRIDSS_OUTPUT/${PATIENT_ID}.gridss.filtered.vcf.gz
##tabix -p vcf $GRIDSS_RAW


    
