#!/bin/bash

#$ -N amber_cobalt
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 16
#$ -l h_rt=12:00:00

#### This script will automate amber and cobalt analyses.
#### Can run either paired tumour-normal or tumour-only mode.
#### Based on https://github.com/hartwigmedical/hmftools
#### https://github.com/hartwigmedical/hmftools/tree/master/amber 
#### https://github.com/hartwigmedical/hmftools/tree/master/cobalt

##Define SGE parameters
CONFIG=$1
IDS=$2
STAGE=$3
TYPE=$4
RUN_TYPE=$5

## Define file IDs and then source config file
PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
source $CONFIG

## Need copynumber package installed in R (done through this conda env)
export PATH=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/r_env/bin:$PATH

# Make work dir for Java if not already present
if [ ! -d $WORK_DIR ]; then
  mkdir -p $WORK_DIR
fi  

# Check if the RUN_TYPE variable is set
if [ -z "$RUN_TYPE" ]; then
  echo "Error: The RUN_TYPE variable is not set."
  exit 1
fi
   
# Check the value of the RUN_TYPE variable
case "$RUN_TYPE" in
  "paired")

    echo "#### Running AMBER in tumour-normal mode for $PATIENT_ID... ####"
    if [ ! -d $OUTPUT_AMBER/${PATIENT_ID} ]; then 
       mkdir -p $OUTPUT_AMBER/${PATIENT_ID}
    fi
    
    java $JVM_OPTS $JVM_TMP_DIR -cp $AMBER_JAR com.hartwig.hmftools.amber.AmberApplication \
       -reference ${PATIENT_ID}N \
       -reference_bam $ALIGNED_BAM_FILE_NORMAL \
       -ref_genome_version 38 \
       -tumor ${PATIENT_ID}${TYPE} \
       -tumor_bam $ALIGNED_BAM_FILE_TUMOR \
       -output_dir $OUTPUT_AMBER/${PATIENT_ID} \
       -loci $GERMLINE_HET_PON \
       -threads 16

    echo "#### Running COBALT in tumour-normal mode for $PATIENT_ID... ####"
    if [ ! -d $OUTPUT_COBALT/${PATIENT_ID} ]; then
       mkdir -p $OUTPUT_COBALT/${PATIENT_ID}
    fi

    if [ ! -f ${PATIENT_ID}${TYPE}.cobalt.ratio.tsv.gz ]; then

       java $JVM_OPTS $JVM_TMP_DIR -cp $COBALT_JAR com.hartwig.hmftools.cobalt.CobaltApplication \
              -reference ${PATIENT_ID}N \
              -reference_bam $ALIGNED_BAM_FILE_NORMAL \
              -tumor ${PATIENT_ID}${TYPE} \
              -tumor_bam $ALIGNED_BAM_FILE_TUMOR \
              -output_dir $OUTPUT_COBALT/${PATIENT_ID} \
              -gc_profile $GC_PROFILE \
              -threads 16
    else 
       echo "#### COBALT output already exists for $PATIENT_ID. Skipping... ####"
    fi

    echo "#### AMBER and COBALT in paired tumour-normal mode done! ####"


    ;;
  "unpaired")

    echo ""#### Running AMBER in tumour-only mode for $PATIENT_ID... "####"
    if [ ! -d $OUTPUT_AMBER/${PATIENT_ID} ]; then 
       mkdir -p $OUTPUT_AMBER/${PATIENT_ID}
    fi

    java $JVM_OPTS $JVM_TMP_DIR -cp $AMBER_JAR com.hartwig.hmftools.amber.AmberApplication \
       -tumor ${PATIENT_ID}${TYPE} \
       -tumor_bam $ALIGNED_BAM_FILE_TUMOR \
       -ref_genome_version 38 \
       -output_dir $OUTPUT_AMBER/${PATIENT_ID} \
       -loci $GERMLINE_HET_PON \
       -threads 16

    echo "#### Running COBALT in tumour-only mode for $PATIENT_ID... ####"
    if [ ! -d $OUTPUT_COBALT/${PATIENT_ID} ]; then
       mkdir -p $OUTPUT_COBALT/${PATIENT_ID}
    fi

    if [ ! -f ${PATIENT_ID}${TYPE}.cobalt.ratio.tsv.gz ]; then
       java $JVM_OPTS $JVM_TMP_DIR -cp $COBALT_JAR com.hartwig.hmftools.cobalt.CobaltApplication \
              -tumor ${PATIENT_ID}${TYPE} \
              -tumor_bam $ALIGNED_BAM_FILE_TUMOR \
              -tumor_only_diploid_bed $TUMOR_ONLY_DIPLOID_BED \
              -output_dir $OUTPUT_COBALT/${PATIENT_ID} \
              -gc_profile $GC_PROFILE \
              -threads 16
    else
       echo "#### COBALT output already exists for $PATIENT_ID. Skipping... ####"
    fi

    echo "#### AMBER and COBALT in tumour-only mode done! ####"

    ;;
  *)
    echo "Error: Invalid value for RUN_TYPE variable."
    exit 1
    ;;
esac



