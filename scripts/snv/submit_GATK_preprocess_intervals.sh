#!/bin/bash

# To run this script, do 
# qsub submit_GATK_preprocess_intervals.sh CONFIG
#
#$ -N preprocessing_cnv
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=24G
#$ -l h_rt=2:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

module load igmm/apps/picard/2.17.11

CONFIG=$1

source $CONFIG

WORK_DIR_GENERIC=$BCBIO_WORK/generic
JVM_OPTS="-Dsamjdk.use_async_io_read_samtools=false -Dsamjdk.use_async_io_write_samtools=true -Dsamjdk.use_async_io_write_tribble=false -Dsamjdk.compression_level=1 -Xms16g -Xmx16g"
JVM_TMP_DIR_GENERIC="-Djava.io.tmpdir=$WORK_DIR_GENERIC"
GATK_JAVA_GENERIC="java $JVM_OPTS $JVM_TMP_DIR_GENERIC -jar $GATK4_JAR"

## Based on GATK tutorial here: https://gatk.broadinstitute.org/hc/en-us/articles/360035531092?id=11682#1
## Based on GLASS workflow here: https://github.com/TheJacksonLaboratory/GLASS/blob/1c554908f00172e9437cac6e75aaf81429852d17/bin/preprocess-intervals.sh
## Collect raw counts data
## Create an interval list from reference genome for WGS data.
## Prepares bins for coverage collection
## Use bin length of 1000 for WGS (250 for WES)
## Separate sex/allosomal chromosomes (can significantly impact on variant calling) and merge these later

$GATK_JAVA_GENERIC PreprocessIntervals \
    -L $INTERVAL_LIST \
    -R $REFERENCE \
    --bin-length 1000 \
    --padding 0 \
    --interval-merging-rule OVERLAPPING_ONLY \
    --exclude-intervals chrX \
    --exclude-intervals chrY \
    -O $CNV/interval_list/autosomal_preprocessed_intervals.interval_list

$GATK_JAVA_GENERIC PreprocessIntervals \
    -L $INTERVAL_LIST \
    -R $REFERENCE \
    --bin-length 1000 \
    --padding 0 \
    --interval-merging-rule OVERLAPPING_ONLY \
    --exclude-intervals chr1 \
    --exclude-intervals chr2 \
    --exclude-intervals chr3 \
    --exclude-intervals chr4 \
    --exclude-intervals chr5 \
    --exclude-intervals chr6 \
    --exclude-intervals chr7 \
    --exclude-intervals chr8 \
    --exclude-intervals chr9 \
    --exclude-intervals chr10 \
    --exclude-intervals chr11 \
    --exclude-intervals chr12 \
    --exclude-intervals chr13 \
    --exclude-intervals chr14 \
    --exclude-intervals chr15 \
    --exclude-intervals chr16 \
    --exclude-intervals chr17 \
    --exclude-intervals chr18 \
    --exclude-intervals chr19 \
    --exclude-intervals chr20 \
    --exclude-intervals chr21 \
    --exclude-intervals chr22 \
    -O $CNV/interval_list/allosomal_preprocessed_intervals.interval_list
   
$GATK_JAVA_GENERIC AnnotateIntervals \
    -R $REFERENCE \
    -L $CNV/interval_list/autosomal_preprocessed_intervals.interval_list \
    --interval-merging-rule OVERLAPPING_ONLY \
    -O $CNV/interval_list/gc_autosomal_preprocessed_intervals.interval_list
    
$GATK_JAVA_GENERIC AnnotateIntervals \
    -R $REFERENCE \
    -L $CNV/interval_list/allosomal_preprocessed_intervals.interval_list \
    --interval-merging-rule OVERLAPPING_ONLY \
    -O $CNV/interval_list/gc_allosomal_preprocessed_intervals.interval_list
    