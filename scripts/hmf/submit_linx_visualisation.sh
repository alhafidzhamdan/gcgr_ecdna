#!/bin/bash

### A more streamlined and flexible version:
## Updated in Summer 2022 
## As per https://github.com/hartwigmedical/hmftools/blob/master/linx/README_VIS.md

# To run this script, do 
# qsub -t 1-n submit_linx_visualisation.sh CONFIG PARAM_FILE
#
#$ -N LINX_VIS
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=8G
#$ -pe sharedmem 8
#$ -l h_rt=22:00:00

##Define SGE parameters

CONFIG=$1
PARAM_FILE=$2

##Define files/paths
LINX_OUTPUT_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/linx/v2

PATIENT_ID=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 1`
TYPE=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 2`
STAGE=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 3`
TUMOR_SNPEFF_VCF_ID=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 4`
LINX_DIR=$LINX_OUTPUT_DIR/${STAGE}/${PATIENT_ID}${TYPE}

source $CONFIG

export PATH=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/linx/bin:$PATH

mkdir -p $WORK_DIR/bcbiotx

echo "Visualising LINX for ${PATIENT_ID}${TYPE}..."
java $JVM_OPTS $JVM_TMP_DIR -cp $LINX_JAR com.hartwig.hmftools.linx.visualiser.SvVisualiser \
    -sample $TUMOR_SNPEFF_VCF_ID \
    -ensembl_data_dir $HMF_ENSEMBLE \
    -vis_file_dir $LINX_DIR \
    -plot_out $LINX_DIR/plot \
    -data_out $LINX_DIR/data \
    -ref_genome_version 38 \
    -circos $CIRCOS




