#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_GATK_calc_contamination.sh CONFIG IDS
#
#$ -N calc_contamination
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=8G
#$ -pe sharedmem 4
#$ -l h_rt=48:00:00

##Define SGE parameters

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
IDS=$2

source $CONFIG

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
CONT_DIR=$QC/calculate_contamination

WORK_DIR_GENERIC=$BCBIO_WORK/${PATIENT_ID}
JVM_OPTS="-Dsamjdk.use_async_io_read_samtools=false -Dsamjdk.use_async_io_write_samtools=true -Dsamjdk.use_async_io_write_tribble=false -Dsamjdk.compression_level=1 -Xms16g -Xmx16g"
JVM_TMP_DIR="-Djava.io.tmpdir=$WORK_DIR_GENERIC"

##################################################################################################################################
## CalculateContamination
##################################################################################################################################
## 
## Estimate contamination with CalculateContamination.
## Calculates the fraction of reads coming from cross-sample contamination, given results from GetPileupSummaries. 
## The resulting contamination table is used with FilterMutectCalls.
## Based on: https://gatk.broadinstitute.org/hc/en-us/articles/360037051972-CalculateContamination
## Like ContEst, this tool estimates contamination based on the signal from ref reads at hom alt sites. 
## However, ContEst uses a probabilistic model that assumes a diploid genotype with no copy number variation and independent contaminating reads. 
## That is, ContEst assumes that each contaminating read is drawn randomly and independently from a different human. 
## This tool uses a simpler estimate of contamination that relaxes these assumptions.
## 
##################################################################################################################################

if [[ -f $CONT_DIR/${PATIENT_ID}T-getpileupsummaries.table && -f $CONT_DIR/${PATIENT_ID}N-getpileupsummaries.table ]]
then
java $JVM_OPTS $JVM_TMP_DIR -jar $GATK4_JAR CalculateContamination \
    -I $CONT_DIR/${PATIENT_ID}T-getpileupsummaries.table \
    --matched-normal $CONT_DIR/${PATIENT_ID}N-getpileupsummaries.table \
    --tumor-segmentation $CONT_DIR/${PATIENT_ID}T-segments.table \
    -O $CONT_DIR/${PATIENT_ID}T-calculatecontamination.table
fi




