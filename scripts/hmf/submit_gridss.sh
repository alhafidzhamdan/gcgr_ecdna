#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_gridss.sh CONFIG IDS
#
#$ -N GRIDSS
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 16
#$ -l h_rt=180:00:00

### Based on https://github.com/PapenfussLab/gridss
### Install latest releases from here https://github.com/PapenfussLab/GRIDSS/releases
### This release is 2.10
### If stops due to lack of time, can be resumed by just resubmitting the script.

CONFIG=$1
IDS=$2

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG
ALIGNED_BAM_FILE_TUMOR=$ALIGNMENTS/${PATIENT_ID}T2/${PATIENT_ID}T2/${PATIENT_ID}T2-ready.bam
ALIGNED_BAM_FILE_NORMAL=$ALIGNMENTS/${PATIENT_ID}N/${PATIENT_ID}N/${PATIENT_ID}N-ready.bam
GRIDSS_RAW=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/gridss/results/${PATIENT_ID}T2.gridss.raw.vcf.gz
GRIDSS_ASSEMBLY=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/gridss/results/${PATIENT_ID}T2.assembly.bam
GRIDSS_WORKING_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/gridss/working_dir/${PATIENT_ID}T2

$GRIDSS \
    --reference $REFERENCE \
    --output $GRIDSS_RAW \
    --assembly $GRIDSS_ASSEMBLY \
    --jvmheap 32g \
    --workingdir $GRIDSS_WORKING_DIR \
    --blacklist $ENCODE_BLACKLIST \
    --jar $GRIDSS_JAR \
    --steps All \
    --maxcoverage 50000 \
    --labels ${PATIENT_ID}N,${PATIENT_ID}T2 \
    $ALIGNED_BAM_FILE_NORMAL $ALIGNED_BAM_FILE_TUMOR





  
