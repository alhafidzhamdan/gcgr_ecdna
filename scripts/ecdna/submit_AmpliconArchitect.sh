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

CONFIG=$1
IDS=$2
STAGE=$3
TYPE=$4
RUN_TYPE=$5

# Check if the RUN_TYPE variable is set
if [ -z "$RUN_TYPE" ]; then
  echo "Error: The RUN_TYPE variable is not set."
  exit 1
fi

## Define files/directories
PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
SAMPLE_ID=${PATIENT_ID}${TYPE}

source $CONFIG

## Based on https://github.com/virajbdeshpande/AmpliconArchitect and 
## https://github.com/jluebeck/PrepareAA
## Installation instructions -> https://github.com/jluebeck/AmpliconArchitect#installation
## Mosek itself can be installed via conda.
## But for my purpose, I installed manually as per https://github.com/virajbdeshpande/AmpliconArchitect#installation
## Will need mosek version 8 licence installed. Refer to https://github.com/jluebeck/AmpliconArchitect#installation
## Obtain licence here: https://www.mosek.com/products/academic-licenses/

## Download AA resource here: https://drive.google.com/drive/folders/18T83A12CfipB0pnGsTs3s-Qqji6sSvCu

## AmpliconArchitect relies on python 2, installed within a separate conda environment `AA`
## Requires pysam, numpy, matplotlib, scipy 
## PURPLE .somatic.tsv output needs to formatted as per https://github.com/virajbdeshpande/AmpliconArchitect/issues/31
## Preprocess cnv-kit generated bed files to filter out unplaced contigs, and to include
## only gain of 5 or more, and segment size 100000 or more
## And will need an aligned tumour bam file.

## Update 01 Nov 2020 - now using PURPLE purity and ploidy adjusted CN calls (rather than CNV kit CN calls)

#################################################################################################################
######################################### GENERATE AA CNV CALLS #################################################
#################################################################################################################

## Generate a prelim PURPLE CNV file for AA
if [[ ! -f $AI_CNV && ! -f $PURPLE_TMP_CNV ]]
then

    echo "#### CNV file from PURPLE for ${SAMPLE_ID} does not exist, running PURPLE... ####"
    echo "#### Running without SNV and SV inputs... ####"

    if [ ! -d $PURPLE_TMP_DIR ]
    then
        echo "#### Creating TMP output directory for $SAMPLE_ID ####"
        mkdir -p $PURPLE_TMP_DIR
    else
        echo "#### TMP Output directory for $SAMPLE_ID already created ####"
    fi
    
    case "$RUN_TYPE" in
        "paired")

        echo "#### Running PURPLE in paired tumour-normal mode for ${SAMPLE_ID}... ####"

        java $JVM_OPTS $JVM_TMP_DIR -jar $PURPLE_JAR \
            -reference ${PATIENT_ID}N \
            -tumor ${PATIENT_ID}T \
            -output_dir $PURPLE_TMP_DIR \
            -threads 16 \
            -amber $OUTPUT_AMBER/${PATIENT_ID} \
            -cobalt $OUTPUT_COBALT/${PATIENT_ID} \
            -gc_profile $GC_PROFILE \
            -ref_genome $REFERENCE \
            -ref_genome_version 38 \
            -ensembl_data_dir $HMF_ENSEMBLE_V533 \
            -no_charts

        echo "#### Formatting for AmplifiedIntervals.py... ####"
        
        cut -f 1-4 $PURPLE_TMP_CNV | sed '1d' | sed 's/\t[^\t]*$/\t1&/' > $AI_CNV

            ;;
        "unpaired")

        echo "#### Running PURPLE in tumour-only mode for ${SAMPLE_ID}... ####"

        java $JVM_OPTS $JVM_TMP_DIR -jar $PURPLE_JAR \
            -tumor ${PATIENT_ID}T \
            -output_dir $PURPLE_TMP_DIR \
            -threads 16 \
            -amber $OUTPUT_AMBER/${PATIENT_ID} \
            -cobalt $OUTPUT_COBALT/${PATIENT_ID} \
            -gc_profile $GC_PROFILE \
            -ref_genome $REFERENCE \
            -ref_genome_version 38 \
            -ensembl_data_dir $HMF_ENSEMBLE_V533 \
            -no_charts
        
        echo "#### Formatting for AmplifiedIntervals.py... ####"

        cut -f 1-4 $PURPLE_TMP_CNV | sed '1d' | sed 's/\t[^\t]*$/\t1&/' > $AI_CNV

    ;;
    *)
        echo "#### Error: Invalid value for RUN_TYPE variable. ####"
        exit 1
        ;;

    esac

else 
    echo "#### CNV file from PURPLE for ${SAMPLE_ID} already exists, skipping PURPLE... ####"
fi

export PATH=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/AA/bin:$PATH
export AA_DATA_REPO=/exports/igmm/eddie/Glioblastoma-WGS/scripts/AmpliconArchitect/data_repo

## Run AmplifiedIntervals.py to generate AA input bed file
if [[ -f $AI_CNV && ! -f $AA_CNV ]]
then
    echo "#### Preprocessing cnv bed files (gain = 5, minimum cn size = 100000) for ${SAMPLE_ID} ####"
    python $AI \
            --bed $AI_CNV \
            --out $AA_PURPLE_BED_DIR/${SAMPLE_ID} \
            --bam $ALIGNED_BAM_FILE_TUMOR \
            --gain 5 \
            --cnsize_min 100000
    echo "#### AmplifiedIntervals.py completed for ${SAMPLE_ID} ####"

fi

## Run AA main script
if [ ! -d $AA_RESULTS_DIR/${SAMPLE_ID} ]
then
    echo "#### Creating output directory for $SAMPLE_ID ####"
    mkdir -p $AA_RESULTS_DIR/${SAMPLE_ID}
else
    echo "#### Removing previous directory for $SAMPLE_ID that was already created ####"
    rm -rf $AA_RESULTS_DIR/${SAMPLE_ID}
    
    echo "#### Creating new output directory for $SAMPLE_ID ####"
    mkdir -p $AA_RESULTS_DIR/${SAMPLE_ID}
    
fi

if [[ -d $AA_RESULTS_DIR/${SAMPLE_ID} && -f $AA_CNV ]]
then
    echo "#### Running AA for ${SAMPLE_ID} using $AA_CNV, only including segments with CN 5 or more, and with min CN size 100000 ####"
    cd $AA_RESULTS_DIR/${SAMPLE_ID}
    python $AA \
        --bam $ALIGNED_BAM_FILE_TUMOR \
        --bed $AA_CNV \
        --out ${SAMPLE_ID} \
        --ref GRCh38
    echo "#### AA run completed for ${SAMPLE_ID} ####"
fi
