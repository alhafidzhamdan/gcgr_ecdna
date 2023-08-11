#!/bin/bash

## qsub -t 1-N submit_GRIPSS.sh CONFIG IDS BATCH

#$ -N GRIPSS
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=8G
#$ -pe sharedmem 8
#$ -l h_rt=72:00:00

CONFIG=$1
IDS=$2
STAGE=$3
BATCH=$4
TYPE=$5

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG

### Based on https://github.com/hartwigmedical/hmftools/blob/master/gripss/README.md
### Uses GRIDSS raw unfiltered VCFs containing calls for both tumour and normal samples
### Filter pon calls, and coerce in known breakpoints

echo "Filter out GRIDSS PONs for ${PATIENT_ID}${TYPE}"
java $JVM_OPTS $JVM_TMP_DIR -cp $GRIPSS_JAR com.hartwig.hmftools.gripss.GripssApplicationKt \
   -ref_genome $REFERENCE \
   -breakend_pon $GRIDSS_PON/gridss_pon_single_breakend.bed \
   -breakpoint_pon $GRIDSS_PON/gridss_pon_breakpoint.bedpe \
   -breakpoint_hotspot $GRIPSS_FUSION \
   -tumor ${PATIENT_ID}${TYPE} \
   -reference ${PATIENT_ID}N \
   -input_vcf $GRIDSS_RAW_VCF \
   -output_vcf $GRIDSS_PON_FILTERED
   
### Then use hard filter to produce a final filtered VCF to be used, both, with PURPLE.
echo "Performing hard filter for PON-filtered VCF for ${PATIENT_ID}${TYPE}"
java $JVM_OPTS $JVM_TMP_DIR -cp $GRIPSS_JAR com.hartwig.hmftools.gripss.GripssHardFilterApplicationKt \
   -input_vcf $GRIDSS_PON_FILTERED \
   -output_vcf $GRIDSS_FINAL_FILTERED




   
