#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_GATK_pileup.sh CONFIG IDS TYPE
#
#$ -N getpileup
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=8G
#$ -pe sharedmem 4
#$ -l h_rt=48:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

module load java/jdk/1.8.0

CONFIG=$1
IDS=$2
TYPE=$3

source $CONFIG

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
SAMPLE_ID=${PATIENT_ID}${TYPE}
ALIGNED_BAM_FILE=$ALIGNMENTS/${SAMPLE_ID}/${SAMPLE_ID}/${SAMPLE_ID}-ready.bam
CONT_DIR=$QC/calculate_contamination
WORK_DIR=$BCBIO_WORK/${SAMPLE_ID}

if [ ! -f $WORK_DIR ]; then mkdir $WORK_DIR; fi

JVM_OPTS="-Dsamjdk.use_async_io_read_samtools=false -Dsamjdk.use_async_io_write_samtools=true -Dsamjdk.use_async_io_write_tribble=false -Dsamjdk.compression_level=1 -Xms16g -Xmx16g"
JVM_TMP_DIR="-Djava.io.tmpdir=$WORK_DIR"

##################################################################################################################################
## GetPileupSummaries
##################################################################################################################################
## This summarises read support for a set number of known variant sites.
## Based on tutorial here; https://gatk.broadinstitute.org/hc/en-us/articles/360036509772-GetPileupSummaries-BETA-
## Summarizes counts of reads that support reference, alternate and other alleles for given sites. 
## Results can be used with CalculateContamination.
## GetPieupSummaries will automatically limit maximum AF as 0.2 and minimum AF as 0.01 ie sites are between AF of 0.01-0.2


java $JVM_OPTS $JVM_TMP_DIR -jar $GATK4_JAR GetPileupSummaries \
    -I $ALIGNED_BAM_FILE \
    -V $KNOWN_GATK_SITES \
    -L $KNOWN_GATK_SITES \
    -O $CONT_DIR/${SAMPLE_ID}-getpileupsummaries.table


