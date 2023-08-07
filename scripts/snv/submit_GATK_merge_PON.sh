#!/bin/bash


##This will merge all batch/sequencer specific PON calls into one unified PON file.
# To run this script, do qsub submit_GATK_merge_PON.sh CONFIG BATCH
#
#$ -N merge_PON
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=32G
#$ -l h_rt=24:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
BATCH=$2

source $CONFIG

WORK_DIR_GENERIC=$BCBIO_WORK/generic
JVM_OPTS="-Dsamjdk.use_async_io_read_samtools=false -Dsamjdk.use_async_io_write_samtools=true -Dsamjdk.use_async_io_write_tribble=false -Dsamjdk.compression_level=1 -Xms16g -Xmx16g"
JVM_TMP_DIR_GENERIC="-Djava.io.tmpdir=$WORK_DIR_GENERIC"


#################################################################################################################################################################################################
## Merge and CreatePON
#################################################################################################################################################################################################
## Because PON calls on normal samples were done individually for each normal, this step
## merges calls from all samples to build a PON
## Protected output, this is the final PON file
## See: 
## https://gatkforums.broadinstitute.org/gatk/discussion/11136/how-to-call-somatic-mutations-using-gatk4-mutect2
## https://gatk.broadinstitute.org/hc/en-us/articles/360037227652
## 
## $PON/${BATCH}.sample_map is a txt file containing paths to all sample specific PON.vcfs
#################################################################################################################################################################################################


## Set all pon files in a database.

##ls -d -1 $PON/${BATCH}*.pon.vcf.gz > $PON/${BATCH}_sample_map
##paste $PARAMS/${BATCH}_GBM_ids.txt $PON/${BATCH}_sample_map > $PON/${BATCH}.sample_map
##rm $PON/${BATCH}_sample_map

if [ -f $PON/${BATCH}.sample_map ]
then
java $JVM_OPTS $JVM_TMP_DIR_GENERIC -jar $GATK4_JAR GenomicsDBImport \
    -R $REFERENCE \
    -L $INTERVAL_LIST \
    --sample-name-map $PON/${BATCH}.sample_map \
    --genomicsdb-workspace-path $PON/${BATCH}_pon_db
fi

## Merge all pon files to batch/sequencer specific PONs
java $JVM_OPTS $JVM_TMP_DIR_GENERIC -jar $GATK4_JAR CreateSomaticPanelOfNormals \
    -R $REFERENCE \
    -V gendb://$PON/${BATCH}_pon_db \
    -O $PON/${BATCH}-merged-pon.vcf.gz




