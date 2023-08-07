#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_GATK_Mutect2.sh CONFIG IDS BATCH
#
#$ -N submit_Mutect2
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 16
#$ -l h_rt=170:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
IDS=$2
BATCH=$3

source $CONFIG

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
TUMOR_DIR=$ALIGNMENTS/${PATIENT_ID}T2/${PATIENT_ID}T2
NORMAL_DIR=$ALIGNMENTS/${PATIENT_ID}N/${PATIENT_ID}N
ALIGNED_BAM_FILE_TUMOR=$TUMOR_DIR/${PATIENT_ID}T2-ready.bam
ALIGNED_BAM_FILE_NORMAL=$NORMAL_DIR/${PATIENT_ID}N-ready.bam

WORK_DIR=$BCBIO_WORK/$PATIENT_ID

if [[ ! -d $WORK_DIR/bcbiotx ]]; then mkdir -p $WORK_DIR/bcbiotx; fi

JVM_OPTS="-Dsamjdk.use_async_io_read_samtools=false -Dsamjdk.use_async_io_write_samtools=true -Dsamjdk.use_async_io_write_tribble=false -Dsamjdk.compression_level=1 -Xms16g -Xmx16g"
JVM_TMP_DIR="-Djava.io.tmpdir=$WORK_DIR/bcbiotx"

## Call SNVs and indels using GATK 4.1.4.1 Mutect2 as detailed here:
## https://github.com/broadinstitute/gatk/blob/master/docs/mutect/mutect.pdf and
## https://gatk.broadinstitute.org/hc/en-us/articles/360035531132?flash_digest=7513af9e1ddf2fb04d32d86c9aa13c7e49b4af2c#
## Output read orientation model file (-orientation-model.tar.gz) via a machine learning approach on filtering out sequencing bias (comparing R1 and R2)
## Split SNV and indels into two files. 
## Filter SNV files with learnreadorientationmodel. 

if [ ! -f $M2_VARIANTS_UNFILTERED/${PATIENT_ID}T-unfiltered.vcf.gz ]
then
java $JVM_OPTS $JVM_TMP_DIR -jar $GATK4_JAR Mutect2 \
    -R $REFERENCE \
    -I $ALIGNED_BAM_FILE_TUMOR \
    -I $ALIGNED_BAM_FILE_NORMAL \
    --normal-sample ${PATIENT_ID}N \
    --intervals $INTERVAL_LIST \
    --germline-resource $GATK_AF_GNOMAD \
    --panel-of-normals $PON/${BATCH}-merged-pon.vcf.gz \
    --dont-use-soft-clipped-bases true \
    --f1r2-tar-gz $READ_BIAS/${PATIENT_ID}T-f1r2.tar.gz \
    -O $M2_VARIANTS_UNFILTERED/${PATIENT_ID}T-unfiltered.vcf.gz \
    --bam-output $M2_VARIANTS_UNFILTERED/${PATIENT_ID}T-unfiltered.bam
fi

if [[ -f $READ_BIAS/${PATIENT_ID}T-f1r2.tar.gz && ! -f $READ_BIAS/${PATIENT_ID}T-read-orientation-model.tar.gz ]]
then
java $JVM_OPTS $JVM_TMP_DIR -jar $GATK4_JAR LearnReadOrientationModel \
    -I $READ_BIAS/${PATIENT_ID}T-f1r2.tar.gz \
    -O $READ_BIAS/${PATIENT_ID}T-read-orientation-model.tar.gz
fi

if [ -f $READ_BIAS/${PATIENT_ID}T-read-orientation-model.tar.gz ]
then
java $JVM_OPTS $JVM_TMP_DIR -jar $GATK4_JAR FilterMutectCalls \
    -R $REFERENCE \
    -V $M2_VARIANTS_UNFILTERED/${PATIENT_ID}T-unfiltered.vcf.gz \
    --tumor-segmentation $CONT_DIR/${PATIENT_ID}T-segments.table \
    --contamination-table $CONT_DIR/${PATIENT_ID}T-calculatecontamination.table \
    --ob-priors $READ_BIAS/${PATIENT_ID}T-read-orientation-model.tar.gz \
    -O $M2_VARIANTS_FILTERED/${PATIENT_ID}T-filtered.vcf.gz
fi









