#!/bin/bash

# To run this script, do 
# qsub -t n submit_AmpliconArchitect.sh IDS
#
#$ -N AI2AA
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 16
#$ -l h_rt=250:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

IDS=$1
TYPE=$2

## Define files/directories
PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
SAMPLE_ID=${PATIENT_ID}${TYPE}

## Based on https://github.com/virajbdeshpande/AmpliconArchitect and 
## https://github.com/jluebeck/PrepareAA
## Installation instructions -> https://github.com/jluebeck/AmpliconArchitect#installation
## Mosek itself can be installed via conda.
## Will need mosek version 8 licence installed. Refer to https://github.com/jluebeck/AmpliconArchitect#installation
## Obtain licence here: https://www.mosek.com/products/academic-licenses/

## Download AA resource here: https://drive.google.com/drive/folders/18T83A12CfipB0pnGsTs3s-Qqji6sSvCu

## AmpliconArchitect relies on python 2, installed within a separate conda environment `AA`
## Requires pysam, numpy, matplotlib, scipy 
## Preprocess cnv-kit generated bed files to filter out unplaced contigs, and to include
## only gain of 5 or more, and segment size 100000 or more
## And will need an aligned bam file.

## Update 01 Nov 2020 - now using PURPLE purity and ploidy adjusted CN calls (rather than CNV kit CN calls)

export PATH=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/AA/bin:$PATH
export AA_DATA_REPO=/exports/igmm/eddie/Glioblastoma-WGS/scripts/AmpliconArchitect/data_repo
AA=/exports/igmm/eddie/Glioblastoma-WGS/scripts/AmpliconArchitect/src/AmpliconArchitect.py
AI=/exports/igmm/eddie/Glioblastoma-WGS/scripts/AmpliconArchitect/src/amplified_intervals.py
CNV_BED=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/ecdna/AA_PURPLE_CN/${PATIENT_ID}${TYPE}.CN_AA.bed
AA_BED_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/ecdna/AA_PURPLE_BED
AA_RESULTS_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/ecdna/AA_PURPLE_RESULTS
ALIGNED_BAM_FILE_TUMOR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/alignments/${SAMPLE_ID}/${SAMPLE_ID}/${SAMPLE_ID}-ready.bam

## Main AA Script:
if [[ -f $CNV_BED && ! -f $AA_BED_DIR/${PATIENT_ID}${TYPE}.bed ]]
then
echo "Preprocessing cnv bed files (gain = 5, minimum cn size = 100000) for ${SAMPLE_ID}"
   python $AI \
        --bed $CNV_BED \
        --out $AA_BED_DIR/${PATIENT_ID}${TYPE}\
        --bam $ALIGNED_BAM_FILE_TUMOR \
        --gain 5 \
        --cnsize_min 100000
elif [ ! -f $CNV_BED ]
then
   echo "CNV segmentation file does not exist."
fi

if [ ! -d $AA_RESULTS_DIR/${PATIENT_ID}${TYPE} ]
then
    echo "Creating output directory for $SAMPLE_ID"
    mkdir -p $AA_RESULTS_DIR/${PATIENT_ID}${TYPE}
else
    echo "Output directory for $SAMPLE_ID already created"
fi

if [ -d $AA_RESULTS_DIR/${PATIENT_ID}${TYPE} ]
then
echo "Running AA for ${SAMPLE_ID} using $AA_BED_DIR/${PATIENT_ID}${TYPE}.bed, only including segments with CN 5 or more, and with min CN size 100000"
    cd $AA_RESULTS_DIR/${PATIENT_ID}${TYPE}
    python $AA \
        --bam $ALIGNED_BAM_FILE_TUMOR \
        --bed $AA_BED_DIR/${PATIENT_ID}${TYPE}.bed \
        --out ${PATIENT_ID}${TYPE} \
        --ref GRCh38
    echo "AA run completed for ${PATIENT_ID}${TYPE}"
fi
    
    

