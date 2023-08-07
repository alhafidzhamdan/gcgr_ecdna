#!/bin/bash

# To run this script, do 
# qsub -t 1-n submit_ensemble_calling.sh CONFIG IDS
#
#$ -N ensemble
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=8G
#$ -pe sharedmem 8
#$ -l h_rt=12:00:00

unset MODULEPATH
. /etc/profile.d/modules.sh

CONFIG=$1
IDS=$2
STAGE=$3
TYPE=$4

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`
TUMOR=${PATIENT_ID}T ## this must correspond to the vcf annotation
NORMAL=${PATIENT_ID}N

source $CONFIG
BCFTOOLS=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/snakemake/bin/bcftools

## 1) Standardise VCF format

VCF2VCF="/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/snakemake/bin/vcf2vcf.pl"

#########################################################################################################################
#### For Strelka2
#########################################################################################################################

#### Annotated Strelka output with AD field

##echo "Annotating Strelka with allelic depth field for ${PATIENT_ID}${TYPE}"
##java $JVM_OPTS $JVM_TMP_DIR -cp $PURPLE_JAR com.hartwig.hmftools.purple.tools.AnnotateStrelkaWithAllelicDepth \
##     -in $S2_VARIANTS_OXOG/${PATIENT_ID}${TYPE}-strelka2.oxog.normalised.passed.filtered.vcf.gz \
##     -out $S2_VARIANTS_OXOG/${PATIENT_ID}${TYPE}-strelka2.AD.annotated.oxog.normalised.passed.filtered.vcf.gz


########
STRELKA2_OLD_VCF=$S2_VARIANTS_OXOG/${PATIENT_ID}${TYPE}-strelka2.AD.annotated.oxog.normalised.passed.filtered.vcf
STRELKA2_NEW_VCF=$S2_VARIANTS_FORMATTED/${PATIENT_ID}${TYPE}.s2.formatted.vcf

$BCFTOOLS index ${STRELKA2_OLD_VCF}.gz

## Unzip vcf:
$BCFTOOLS view \
    -Ov \
    -o $STRELKA2_OLD_VCF \
    ${STRELKA2_OLD_VCF}.gz

$VCF2VCF \
    --input-vcf $STRELKA2_OLD_VCF \
    --output-vcf $STRELKA2_NEW_VCF \
    --vcf-tumor-id $TUMOR \
    --vcf-normal-id $NORMAL \
    --ref-fasta $REFERENCE 

$BCFTOOLS view \
    -Oz \
    -o ${STRELKA2_NEW_VCF}.gz \
    $STRELKA2_NEW_VCF

$BCFTOOLS index ${STRELKA2_NEW_VCF}.gz

rm $STRELKA2_OLD_VCF
rm $STRELKA2_NEW_VCF

#########################################################################################################################
#### For Mutect2
#########################################################################################################################

MUTECT2_OLD_VCF=$M2_VARIANTS_PASSED/${PATIENT_ID}${TYPE}-Mutect2.normalised.passed.filtered.vcf
MUTECT2_NEW_VCF=$M2_VARIANTS_FORMATTED/${PATIENT_ID}${TYPE}.m2.formatted.vcf

$BCFTOOLS index ${MUTECT2_OLD_VCF}.gz

$BCFTOOLS view \
    -Ov \
    -o $MUTECT2_OLD_VCF \
    ${MUTECT2_OLD_VCF}.gz

$VCF2VCF \
    --input-vcf $MUTECT2_OLD_VCF \
    --output-vcf $MUTECT2_NEW_VCF \
    --vcf-tumor-id $TUMOR \
    --vcf-normal-id $NORMAL \
    --ref-fasta $REFERENCE 

$BCFTOOLS view \
    -Oz \
    -o ${MUTECT2_NEW_VCF}.gz \
    $MUTECT2_NEW_VCF

$BCFTOOLS index ${MUTECT2_NEW_VCF}.gz

rm $MUTECT2_OLD_VCF
rm $MUTECT2_NEW_VCF

#########################################################################################################################
#### For Vardict
#########################################################################################################################

VARDICT_OLD_VCF=$VARDICT_VARIANTS_OXOG/${PATIENT_ID}${TYPE}-vardict.oxog.normalised.passed.filtered.vcf
VARDICT_NEW_VCF=$VARDICT_VARIANTS_FORMATTED/${PATIENT_ID}${TYPE}.var.formatted.vcf

$BCFTOOLS index ${VARDICT_OLD_VCF}.gz

$BCFTOOLS view \
    -Ov \
    -o $VARDICT_OLD_VCF \
    ${VARDICT_OLD_VCF}.gz

$VCF2VCF \
    --input-vcf $VARDICT_OLD_VCF \
    --output-vcf $VARDICT_NEW_VCF \
    --vcf-tumor-id $TUMOR \
    --vcf-normal-id $NORMAL \
    --ref-fasta $REFERENCE 

$BCFTOOLS view \
    -Oz \
    -o ${VARDICT_NEW_VCF}.gz \
    $VARDICT_NEW_VCF

$BCFTOOLS index ${VARDICT_NEW_VCF}.gz

rm $VARDICT_OLD_VCF
rm $VARDICT_NEW_VCF

#########################################################################################################################

## 2) Intersect calls between 2 separate callers

## Mutect2-Strelka2 intersect
$BCFTOOLS isec -c none ${MUTECT2_NEW_VCF}.gz ${STRELKA2_NEW_VCF}.gz -n =2 -w 1 -O z -p $M2_S2/${PATIENT_ID}${TYPE}
mv $M2_S2/${PATIENT_ID}${TYPE}/0000.vcf.gz $M2_S2/${PATIENT_ID}${TYPE}.m2s2.vcf.gz
mv $M2_S2/${PATIENT_ID}${TYPE}/0000.vcf.gz.tbi $M2_S2/${PATIENT_ID}${TYPE}.m2s2.vcf.gz.tbi

## Mutect2-Vardict intersect
$BCFTOOLS isec -c none ${MUTECT2_NEW_VCF}.gz ${VARDICT_NEW_VCF}.gz -n =2 -w 1 -O z -p $M2_Var/${PATIENT_ID}${TYPE}
mv $M2_Var/${PATIENT_ID}${TYPE}/0000.vcf.gz $M2_Var/${PATIENT_ID}${TYPE}.m2var.vcf.gz
mv $M2_Var/${PATIENT_ID}${TYPE}/0000.vcf.gz.tbi $M2_Var/${PATIENT_ID}${TYPE}.m2var.vcf.gz.tbi

## Strelka2-Vardict intersect
$BCFTOOLS isec -c none ${STRELKA2_NEW_VCF}.gz ${VARDICT_NEW_VCF}.gz -n =2 -w 1 -O z -p $S2_Var/${PATIENT_ID}${TYPE}
mv $S2_Var/${PATIENT_ID}${TYPE}/0000.vcf.gz $S2_Var/${PATIENT_ID}${TYPE}.s2var.vcf.gz
mv $S2_Var/${PATIENT_ID}${TYPE}/0000.vcf.gz.tbi $S2_Var/${PATIENT_ID}${TYPE}.s2var.vcf.gz.tbi

#########################################################################################################################

## 3) Merge all intersections to create an ensemble call set

$BCFTOOLS concat -a -d none \
    -Oz \
    -o $ENSEMBLE_DIR/${PATIENT_ID}${TYPE}.ssv.vcf.gz \
    $M2_S2/${PATIENT_ID}${TYPE}.m2s2.vcf.gz $M2_Var/${PATIENT_ID}${TYPE}.m2var.vcf.gz $S2_Var/${PATIENT_ID}${TYPE}.s2var.vcf.gz
    
$BCFTOOLS index $ENSEMBLE_DIR/${PATIENT_ID}${TYPE}.ssv.vcf.gz
  











