#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_GRIDSS_repeatMasker.sh CONFIG IDS
#
#$ -N GRIDSS_RM
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -l h_rt=20:00:00

### Based on https://github.com/PapenfussLab/gridss
### Install latest releases from here https://github.com/PapenfussLab/GRIDSS/releases
### This release is 2.10
### Need to tweak original script (gridss_annotate_vcf_repeatmasker.sh) to increase java heap requirement for RepeatMasker from 64Mb to >2g
### Update 11/8/23: Installation of repeatmasker done via separate conda env and installed with conda

CONFIG=$1
IDS=$2
STAGE=$3
BATCH=$4
TYPE=$5

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG

# /exports/igmm/eddie/Glioblastoma-WGS/scripts/TRF-4.09.1/build/src/trf
# /exports/igmm/eddie/Glioblastoma-WGS/scripts/rmblast-2.14.0/bin

## Generate RM annotated high confidence SV call
$GRIDSS_RM \
    $GRIDSS_FINAL_FILTERED \
    -o $GRIDSS_FINAL_FILTERED_RM \
    -j $GRIDSS_JAR \
    -w $GRIDSS_WORKING_DIR \
    --rm $REPEAT_MASKER_EXE \
    -t 16

## Generate RM annotated low confidence SV call
$GRIDSS_RM \
    $GRIDSS_PON_FILTERED \
    -o $GRIDSS_PON_FILTERED_RM \
    -j $GRIDSS_JAR \
    -w $GRIDSS_WORKING_DIR \
    --rm $REPEAT_MASKER_EXE \
    -t 16
     









