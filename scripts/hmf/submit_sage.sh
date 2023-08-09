#!/bin/bash

#$ -N SAGE
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 16
#$ -l h_rt=48:00:00

CONFIG=$1
IDS=$2
STAGE=$3
TYPE=$4
RUN_TYPE=$5

## TYPE represents tumour bam annotation, whether T or T1/T2 (in case of paired samples)

## Define file IDs
PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG

### Based on https://github.com/hartwigmedical/hmftools/blob/master/sage/README.md
### Also draws from https://github.com/toddajohnson
### Can be run in tumour-only mode. 
### SAGE is optimised for 100x coverage samples.
### Can change mode to run for lower coverage samples (e.g. 30x) by changin some key parameters as detailed in github repository.
### This works for both paired and unpaired samples.

# Make TMP dir for Java if not already present
if [[! -d $JVM_TMP_DIR ]]; then
  mkdir -p $JVM_TMP_DIR
fi  

# Check if the RUN_TYPE variable is set
if [ -z "$RUN_TYPE" ]; then
  echo "Error: The RUN_TYPE variable is not set."
  exit 1
fi

# Check the value of the RUN_TYPE variable
case "$RUN_TYPE" in
  "paired")

    echo "#### Running SAGE in tumour-normal mode for $PATIENT_ID... ####"

    if [[ ! -f $SAGE_SOMATIC_VCF ]]; then
      echo "#### SAGE somatic VCF file does not exist for $PATIENT_ID. Running... ####"
      java $JVM_OPTS $JVM_TMP_DIR -cp $SAGE_JAR com.hartwig.hmftools.sage.SageApplication \
        -threads 16 \
        -reference ${PATIENT_ID}N -reference_bam $ALIGNED_BAM_FILE_NORMAL \
        -tumor ${PATIENT_ID}${TYPE} -tumor_bam $ALIGNED_BAM_FILE_TUMOR \
        -ref_genome_version 38 \
        -ref_genome $REFERENCE \
        -hotspots $SOMATIC_HOTSPOTS_V533 \
        -panel_bed $ACTIONABLE_V533 \
        -high_confidence_bed $HIGH_CONF_BED_V533 \
        -ensembl_data_dir $HMF_ENSEMBLE_V533 \
        -hotspot_min_tumor_qual 40 \
        -panel_min_tumor_qual 60 \
        -high_confidence_min_tumor_qual 100 \
        -low_confidence_min_tumor_qual 150 \
        -include_mt \
        -out $SAGE_SOMATIC_VCF

      echo "#### Done! ####"
    fi

    if [[ ! -f $SAGE_GERMLINE_VCF ]]; then
      echo "#### SAGE germline VCF file does not exist for $PATIENT_ID. Running... ####"
      ## Based on https://github.com/hartwigmedical/hmftools/blob/master/sage/GERMLINE.md
      java $JVM_OPTS $JVM_TMP_DIR -cp $SAGE_JAR com.hartwig.hmftools.sage.SageApplication \
        -threads 16 \
        -tumor ${PATIENT_ID}N -tumor_bam $ALIGNED_BAM_FILE_NORMAL \
        -reference ${PATIENT_ID}${TYPE} -reference_bam $ALIGNED_BAM_FILE_TUMOR \
        -ref_genome_version 38 \
        -ref_genome $REFERENCE \
        -hotspots $GERMLINE_HOTSPOTS_V533 \
        -panel_bed $ACTIONABLE_V533 \
        -high_confidence_bed $HIGH_CONF_BED_V533 \
        -ensembl_data_dir $HMF_ENSEMBLE_V533 \
        -hotspot_min_tumor_qual 40 \
        -panel_min_tumor_qual 60 \
        -high_confidence_min_tumor_qual 100 \
        -low_confidence_min_tumor_qual 150 \
        -ref_sample_count 0 \
        -panel_only \
        -hotspot_max_germline_vaf 100 \
        -hotspot_max_germline_rel_raw_base_qual 100 \
        -high_confidence_max_germline_vaf 100 \
        -low_confidence_max_germline_vaf 100 \
        -panel_max_germline_vaf 100 \
        -panel_max_germline_rel_raw_base_qual 100 \
        -hotspot_max_germline_rel_raw_base_qual 100 \
        -panel_max_germline_rel_raw_base_qual 100 \
        -high_confidence_max_germline_rel_raw_base_qual 100 \
        -low_confidence_max_germline_rel_raw_base_qual 100 \
        -include_mt \
        -out $SAGE_GERMLINE_VCF

      echo "#### Done! ####"
    fi

    ;;
  "unpaired")
    echo "Running SAGE in tumour-only mode for $PATIENT_ID..."

    if [[ ! -f $SAGE_SOMATIC_VCF ]]; then
      echo "#### SAGE somatic VCF file does not exist for $PATIENT_ID. Running... ####"
      java $JVM_OPTS $JVM_TMP_DIR -cp $SAGE_JAR com.hartwig.hmftools.sage.SageApplication \
        -threads 16 \
        -tumor ${PATIENT_ID}${TYPE} -tumor_bam $ALIGNED_BAM_FILE_TUMOR \
        -ref_genome_version 38 \
        -ref_genome $REFERENCE \
        -hotspots $SOMATIC_HOTSPOTS_V533 \
        -panel_bed $ACTIONABLE_V533 \
        -high_confidence_bed $HIGH_CONF_BED_V533 \
        -ensembl_data_dir $HMF_ENSEMBLE_V533 \
        -hotspot_min_tumor_qual 40 \
        -panel_min_tumor_qual 60 \
        -high_confidence_min_tumor_qual 100 \
        -low_confidence_min_tumor_qual 150 \
        -include_mt \
        -out $SAGE_SOMATIC_VCF

      echo "#### Done! ####"
    fi

    ;;
  *)
    echo "Error: Invalid value for RUN_TYPE variable."
    exit 1
    ;;
esac