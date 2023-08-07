#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_amber-cobalt.sh CONFIG IDS
#
#$ -N amber_cobalt
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -l h_rt=72:00:00

#### This script will automate amber and cobalt analyses.
#### Based on https://github.com/hartwigmedical/hmftools

##Define SGE parameters

CONFIG=$1
IDS=$2
STAGE=$3
TYPE=$4

##Define files/paths
PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG
ALIGNED_BAM_FILE_TUMOR=$ALIGNMENTS/${PATIENT_ID}${TYPE}/${PATIENT_ID}${TYPE}/${PATIENT_ID}${TYPE}-ready.bam
ALIGNED_BAM_FILE_NORMAL=$ALIGNMENTS/${PATIENT_ID}N/${PATIENT_ID}N/${PATIENT_ID}N-ready.bam

## Need copynumber package installed in R (done through this conda env)
export PATH=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/r_env/bin:$PATH

#### AMBER
echo "Running Amber for ${PATIENT_ID}${TYPE}"
java $JVM_OPTS $JVM_TMP_DIR -cp $AMBER_JAR com.hartwig.hmftools.amber.AmberApplication \
       -reference ${PATIENT_ID}N \
       -reference_bam $ALIGNED_BAM_FILE_NORMAL \
       -tumor ${PATIENT_ID}${TYPE} \
       -tumor_bam $ALIGNED_BAM_FILE_TUMOR \
       -output_dir $OUTPUT_AMBER/${PATIENT_ID}${TYPE} \
       -threads 16 \
       -loci $HET

#### COBALT
echo "Running Cobalt for ${PATIENT_ID}${TYPE}"
java $JVM_OPTS $JVM_TMP_DIR -cp $COBALT_JAR com.hartwig.hmftools.cobalt.CountBamLinesApplication \
        -reference ${PATIENT_ID}N \
        -reference_bam $ALIGNED_BAM_FILE_NORMAL \
        -tumor ${PATIENT_ID}${TYPE} \
        -tumor_bam $ALIGNED_BAM_FILE_TUMOR \
        -output_dir $OUTPUT_COBALT/${PATIENT_ID}${TYPE} \
        -threads 16 \
        -gc_profile $GC_PROFILE
   
