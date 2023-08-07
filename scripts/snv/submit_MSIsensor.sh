#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_MSIsensor.sh CONFIG IDS
#
#$ -N MSI
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=8G
#$ -pe sharedmem 8
#$ -l h_rt=72:00:00

CONFIG=$1
IDS=$2
TYPE=$3
OUT_TYPE=$4

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG

## Just run once
## Create microsatellite list from hg38 using $MSISENSOR scan -d $REFERENCE -o $RESOURCES/hg38.microsatellites.list

## MSI scoring (main function)
## Use -c 15 as bam files are WGS data
## -z 1 is used to normalised coverage between T/N bams

if [[ ! -e $MSI_DIR/${PATIENT_ID}${OUT_TYPE}.MSI.log ]]
then
$MSISENSOR msi -d $RESOURCES/hg38.microsatellites.list \
    -n $ALIGNED_BAM_FILE_NORMAL \
    -t $ALIGNED_BAM_FILE_TUMOR \
    -c 15 \
    -z 1 \
    -o ${PATIENT_ID}${OUT_TYPE} &> $MSI_DIR/${PATIENT_ID}${OUT_TYPE}.MSI.log
fi 
 
 
 
