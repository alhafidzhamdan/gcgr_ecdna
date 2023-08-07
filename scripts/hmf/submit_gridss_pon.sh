#!/bin/bash

#$ -N gridssPON
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -l h_rt=12:00:00

### This script calls panel of normals from GRIDSS called VCFs.
### It generates bedpe and bed files which need to be named generically.
### Hence must create a parent folder file for each batch.
### Need at least 16G of ram
### VCF files also need to be decompressed

CONFIG=$1
BATCH=$2

source $CONFIG

if [ ! -d $GRIDSS_PON/${BATCH}/gridss_pon_breakpoint.bedpe ]
then
    if [ $BATCH == GCGR ]
    then
        java -Xmx8g \
        	-cp $GRIDSS_JAR \
        	gridss.GeneratePonBedpe \
        	$(ls -1 $GRIDSS_OUTPUT/E*.gridss.raw.vcf | awk ' { print "INPUT=" $0 }') \
        	O=$GRIDSS_PON/${BATCH}/gridss_pon_breakpoint.raw.bedpe \
        	SBO=$GRIDSS_PON/${BATCH}/gridss_pon_single_breakend.raw.bed \
        	THREADS=12 \
        	NORMAL_ORDINAL=0 \
        	REFERENCE_SEQUENCE=$REFERENCE
        cat $GRIDSS_PON/${BATCH}/gridss_pon_single_breakend.raw.bed | awk '$5>=3' > $GRIDSS_PON/${BATCH}/gridss_pon_single_breakend.bed
        cat $GRIDSS_PON/${BATCH}/gridss_pon_breakpoint.raw.bedpe | awk '$8>=3' > $GRIDSS_PON/${BATCH}/gridss_pon_breakpoint.bedpe
        rm $GRIDSS_PON/${BATCH}/*raw*
    elif [ $BATCH == DBGAP_TCGA ]
    then 
        java -Xmx8g \
        	-cp $GRIDSS_JAR \
        	gridss.GeneratePonBedpe \
        	$(ls -1 $GRIDSS_OUTPUT/DO*.gridss.raw.vcf | awk ' { print "INPUT=" $0 }') \
        	O=$GRIDSS_PON/${BATCH}/gridss_pon_breakpoint.raw.bedpe \
        	SBO=$GRIDSS_PON/${BATCH}/gridss_pon_single_breakend.raw.bed \
        	THREADS=12 \
        	NORMAL_ORDINAL=0 \
        	REFERENCE_SEQUENCE=$REFERENCE
        cat $GRIDSS_PON/${BATCH}/gridss_pon_single_breakend.raw.bed | awk '$5>=3' > $GRIDSS_PON/${BATCH}/gridss_pon_single_breakend.bed
        cat $GRIDSS_PON/${BATCH}/gridss_pon_breakpoint.raw.bedpe | awk '$8>=3' > $GRIDSS_PON/${BATCH}/gridss_pon_breakpoint.bedpe
        rm $GRIDSS_PON/${BATCH}/*raw*
    else
        java -Xmx8g \
        	-cp $GRIDSS_JAR \
        	gridss.GeneratePonBedpe \
        	$(ls -1 $GRIDSS_OUTPUT/${BATCH}/${BATCH}*.gridss.raw.vcf | awk ' { print "INPUT=" $0 }') \
        	O=$GRIDSS_PON/${BATCH}/gridss_pon_breakpoint.raw.bedpe \
        	SBO=$GRIDSS_PON/${BATCH}/gridss_pon_single_breakend.raw.bed \
        	THREADS=12 \
        	NORMAL_ORDINAL=0 \
        	REFERENCE_SEQUENCE=$REFERENCE
        cat $GRIDSS_PON/${BATCH}/gridss_pon_single_breakend.raw.bed | awk '$5>=3' > $GRIDSS_PON/${BATCH}/gridss_pon_single_breakend.bed
        cat $GRIDSS_PON/${BATCH}/gridss_pon_breakpoint.raw.bedpe | awk '$8>=3' > $GRIDSS_PON/${BATCH}/gridss_pon_breakpoint.bedpe
        rm $GRIDSS_PON/${BATCH}/*raw*
    fi
fi

    
    
