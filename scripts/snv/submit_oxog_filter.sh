#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_oxog_filter.sh CONFIG IDS
##
#$ -N oxogfilter
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -l h_rt=50:00:00
#$ -pe sharedmem 8

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
IDS=$2
STAGE=$3
TYPE=$4


PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG

INPUT_S2=$S2_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-strelka2.normalised.passed.filtered.vcf.gz
OUTPUT_ANNO_S2=$S2_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-strelka2.annotated.normalised.passed.filtered.vcf.gz
OUTPUT_S2=$S2_VARIANTS_OXOG/${PATIENT_ID}${TYPE}-strelka2.oxog.normalised.passed.filtered.vcf.gz

INPUT_VAR=$VARDICT_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-vardict.normalised.passed.filtered.vcf.gz
OUTPUT_ANNO_VAR=$VARDICT_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-vardict.annotated.normalised.passed.filtered.vcf.gz
OUTPUT_VAR=$VARDICT_VARIANTS_OXOG/${PATIENT_ID}${TYPE}-vardict.oxog.normalised.passed.filtered.vcf.gz

METRICS_FILE=$METRICS/${PATIENT_ID}${TYPE}_artifact.pre_adapter_detail_metrics

TUMOR_DIR=$ALIGNMENTS/${PATIENT_ID}${TYPE}/${PATIENT_ID}${TYPE}
NORMAL_DIR=$ALIGNMENTS/${PATIENT_ID}N/${PATIENT_ID}N
ALIGNED_BAM_FILE_TUMOR=$TUMOR_DIR/${PATIENT_ID}${TYPE}-ready.bam
ALIGNED_BAM_FILE_NORMAL=$NORMAL_DIR/${PATIENT_ID}N-ready.bam



#################################################################################################################################################################################################
## CollectSequencingArtifactMetrics
############################################################################################################################################################################################################# 
##
## Collect metrics to quantify single-base sequencing artifacts.
## 
## GATK Best practice, based on this tutorial -> 
## https://gatk.broadinstitute.org/hc/en-us/articles/360037592531-CollectSequencingArtifactMetrics-Picard-
## https://gatk.broadinstitute.org/hc/en-us/articles/360037060232-FilterByOrientationBias-EXPERIMENTAL-
## 
## Also used based on pipeline used by PCAWG as detailed here: 
## https://www.readcube.com/library/347a3c37-ef6b-439b-9be5-35fd848757e2:82bcf7ad-650b-4d8b-9115-38d0e4028ca7
## 
## This tool examines two sources of sequencing errors associated with hybrid selection protocols. 
## These errors are divided into two broad categories, pre-adapter and bait-bias. 
## 
## Pre-adapter errors can arise from laboratory manipulations of a nucleic acid sample e.g. shearing 
## and occur prior to the ligation of adapters for PCR amplification (hence the name pre-adapter).
##
## Bait-bias artifacts occur during or after the target selection step, 
## and correlate with substitution rates that are 'biased', or higher for sites having one base 
## on the reference/positive strand relative to sites having the complementary base on that strand. 
## For example, during the target selection step, a (G>T) artifact might result in a higher substitution rate 
## at sites with a G on the positive strand (and C on the negative), 
## relative to sites with the flip (C positive)/(G negative). This is known as the 'G-Ref' artifact.
## Ensure that filtered vcfs are normalised.
##
################################################################################################################################################################################################################################################################################################

## Generate the oxog bias metrics

if [ ! -f $METRICS/${PATIENT_ID}${TYPE}_oxog_metrics.txt ]
then
    echo "Generating oxog metrics for ${PATIENT_ID}${TYPE}"
    java $JVM_OPTS $JVM_TMP_DIR -jar $PICARD_JAR CollectOxoGMetrics \
        I=$ALIGNED_BAM_FILE_TUMOR \
        R=$REFERENCE \
        O=$METRICS/${PATIENT_ID}${TYPE}_oxog_metrics.txt
else
    echo "Oxog metrics already generated"
fi

if [ ! -f $METRICS_FILE ]
then
    echo "Generating sequencing artifact metrics for ${PATIENT_ID}${TYPE}"
    java $JVM_OPTS $JVM_TMP_DIR -jar $PICARD_JAR CollectSequencingArtifactMetrics \
         I=$ALIGNED_BAM_FILE_TUMOR \
         O=$METRICS/${PATIENT_ID}${TYPE}_artifact \
         R=$REFERENCE
else 
    echo "Sequencing artifact metrics already generated"
fi

## Annotate VCFs with oxog bias field

if [ -f $METRICS_FILE ]
then
    echo "Annotating oxog artifacts from Strelka2 call for ${PATIENT_ID}${TYPE}"
    $GATK4 FilterByOrientationBias \
      --variant $INPUT_S2 \
      --artifact-modes 'G/T' \
      --pre-adapter-detail-file $METRICS_FILE \
      --output $OUTPUT_ANNO_S2
else
    echo "Strelka2 call for ${PATIENT_ID}${TYPE} already annotated"
fi

if [ -f $METRICS_FILE ]
then
    echo "Annotating oxog artifacts from Vardict call for ${PATIENT_ID}${TYPE}"
    $GATK4 FilterByOrientationBias \
      --variant $INPUT_VAR \
      --artifact-modes 'G/T' \
      --pre-adapter-detail-file $METRICS_FILE \
      --output $OUTPUT_ANNO_VAR
else
    echo "Vardict call for ${PATIENT_ID}${TYPE} already annotated"
fi

## Filtering out oxog artifacts
BCFTOOLS=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/snakemake/bin/bcftools

$BCFTOOLS view -Ov -o $S2_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-strelka2.annotated.normalised.passed.filtered.vcf $OUTPUT_ANNO_S2
$BCFTOOLS view -f PASS $S2_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-strelka2.annotated.normalised.passed.filtered.vcf | \
$BCFTOOLS sort \
   -Oz \
   -o $OUTPUT_S2

$BCFTOOLS index -t $OUTPUT_S2

$BCFTOOLS view -Ov -o $VARDICT_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-vardict.annotated.normalised.passed.filtered.vcf $OUTPUT_ANNO_VAR
$BCFTOOLS view -f PASS $VARDICT_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-vardict.annotated.normalised.passed.filtered.vcf | \
$BCFTOOLS sort \
   -Oz \
   -o $OUTPUT_VAR

$BCFTOOLS index -t $OUTPUT_VAR



