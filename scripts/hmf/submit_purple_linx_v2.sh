#!/bin/bash

### A more streamlined and flexible version:
## Updated in Summer 2022 

# To run this script, do 
# qsub -t 1-n submit_PURPLE-LINX.sh CONFIG IDS
#
#$ -N PURPLE-LINX-V2
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=12G
#$ -pe sharedmem 12
#$ -l h_rt=22:00:00

#### July '22: Updated PURPLE and LINX to 3.5 and 1.2 respectively
#### Tried running with germline VCF, did not work

##Define SGE parameters

CONFIG=$1
PARAM_FILE=$2

source $CONFIG

##Define files/paths
PURPLE_OUTPUT_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/purple/v2
LINX_OUTPUT_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/linx/v2

PATIENT_ID=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 1`
TYPE=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 2`
STAGE=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 3`
TUMOR_SNPEFF_VCF_ID=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 4`
SNPEFF_VCF_FILE=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 5`
GERMLINE_VCF=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 6`
AMBER_DIR=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 7`
COBALT_DIR=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 8`
GRIDSS_FILTERED_FILE=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 9`
GRIDSS_PON_FILE=`head -n $SGE_TASK_ID $PARAM_FILE | tail -n 1 | cut -f 10`
PURPLE_DIR=$PURPLE_OUTPUT_DIR/${STAGE}/${PATIENT_ID}${TYPE}
LINX_DIR=$LINX_OUTPUT_DIR/${STAGE}/${PATIENT_ID}${TYPE}
PURPLE_SV_VCF=$PURPLE_DIR/${TUMOR_SNPEFF_VCF_ID}.purple.sv.vcf.gz

export PATH=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/purple/bin:$PATH
export PATH=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/linx/bin:$PATH

if [[ ! -f $PURPLE_SV_VCF ]]; then
echo "Running PURPLE for ${PATIENT_ID}${TYPE}"
mkdir -p $PURPLE_DIR
java $JVM_OPTS $JVM_TMP_DIR -jar $PURPLE_JAR \
       -reference ${PATIENT_ID}N \
       -tumor $TUMOR_SNPEFF_VCF_ID \
       -output_dir $PURPLE_DIR \
       -amber $AMBER_DIR \
       -cobalt $COBALT_DIR \
       -gc_profile $GC_PROFILE \
       -ref_genome $REFERENCE \
       -ref_genome_version 38 \
       -somatic_vcf $SNPEFF_VCF_FILE \
       -structural_vcf $GRIDSS_FILTERED_FILE \
       -sv_recovery_vcf $GRIDSS_PON_FILE \
       -run_drivers \
       -somatic_hotspots $SOMATIC_HOTSPOTS \
       -driver_gene_panel $DRIVER_GENE_PANEL \
       -circos $CIRCOS \
       -ensembl_data_dir $HMF_ENSEMBLE

fi

echo "Running LINX for ${PATIENT_ID}${TYPE}..."
mkdir -p $LINX_DIR

java $JVM_OPTS $JVM_TMP_DIR -jar $LINX_JAR \
    -sample $TUMOR_SNPEFF_VCF_ID \
    -sv_vcf $PURPLE_SV_VCF \
    -purple_dir $PURPLE_DIR \
    -output_dir $LINX_DIR \
    -ref_genome_version 38 \
    -check_drivers \
    -driver_gene_panel $DRIVER_GENE_PANEL \
    -fragile_site_file $FRAGILE_SITES \
    -line_element_file $LINE_ELEMENTS \
    -ensembl_data_dir $HMF_ENSEMBLE \
    -check_fusions \
    -known_fusion_file $HMF_FUSION \
    -log_debug \
    -write_vis_data \
    -write_all_vis_fusions

mkdir -p $LINX_DIR/plot
mkdir -p $LINX_DIR/data

echo "Visualising LINX for ${PATIENT_ID}${TYPE}..."
java $JVM_OPTS $JVM_TMP_DIR -cp $LINX_JAR com.hartwig.hmftools.linx.visualiser.SvVisualiser \
    -sample $TUMOR_SNPEFF_VCF_ID \
    -ensembl_data_dir $HMF_ENSEMBLE \
    -vis_file_dir $LINX_DIR \
    -plot_out $LINX_DIR/plot \
    -data_out $LINX_DIR/data \
    -ref_genome_version 38 \
    -circos $CIRCOS



