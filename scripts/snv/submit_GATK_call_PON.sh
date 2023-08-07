#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_GATK_call_PON.sh CONFIG IDS
#
#$ -N call_PON
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 8
#$ -l h_rt=72:00:00

##Define SGE parameters

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
IDS=$2

##Define files/paths

source $CONFIG

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
NORMAL_DIR=$ALIGNMENTS/${PATIENT_ID}N/${PATIENT_ID}N
ALIGNED_BAM_FILE_NORMAL=$NORMAL_DIR/${PATIENT_ID}N-ready.bam

if [[ ! -f $BCBIO_WORK/$PATIENT_ID ]]
then
    mkdir $BCBIO_WORK/$PATIENT_ID
fi

WORK_DIR_GENERIC=$BCBIO_WORK/$PATIENT_ID
JVM_OPTS="-Dsamjdk.use_async_io_read_samtools=false -Dsamjdk.use_async_io_write_samtools=true -Dsamjdk.use_async_io_write_tribble=false -Dsamjdk.compression_level=1 -Xms16g -Xmx16g"
JVM_TMP_DIR="-Djava.io.tmpdir=$WORK_DIR_GENERIC"


##################################################################################################################################
## CallPON
##################################################################################################################################
## This rule uses Mutect2 in tumor-only mode (artifact detection mode) to detect ALL variants in a given non-tumor sample. 
## No germline resource in included because this would exclude these variants from the PON
## See: https://gatkforums.broadinstitute.org/gatk/discussion/11136/how-to-call-somatic-mutations-using-gatk4-mutect2
##################################################################################################################################


java $JVM_OPTS $JVM_TMP_DIR -jar $GATK4_JAR Mutect2 \
    -R $REFERENCE \
    -I $ALIGNED_BAM_FILE_NORMAL \
    -L $INTERVAL_LIST \
    -max-mnp-distance 0 \
    -O $PON/${PATIENT_ID}.pon.vcf.gz

    
    
    

