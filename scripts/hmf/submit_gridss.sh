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
STAGE=$3
TYPE=$4
RUN_TYPE=$5

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG

GRIDSS_ASSEMBLY=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/gridss/results/

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
    --labels ${PATIENT_ID}N,${PATIENT_ID}${TYPE} \
    $ALIGNED_BAM_FILE_NORMAL $ALIGNED_BAM_FILE_TUMOR





  
