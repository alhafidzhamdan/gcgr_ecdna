#!/usr/bin/bash

#Configuration file for common directory and file locations for scripts

## Paths:
export PATH=/exports/igmm/eddie/NextGenResources/bcbio-1.1.5/anaconda/bin:$PATH
export PATH=/exports/igmm/eddie/NextGenResources/bcbio-1.1.5/tools/bin:$PATH 
export PATH=/exports/igmm/eddie/NextGenResources/bcbio-1.1.5:$PATH
export PATH=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/bin:$PATH
export PATH=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/snakemake/bin:$PATH

## Base:
BASE=/exports/igmm/eddie/Glioblastoma-WGS
WGS=/exports/igmm/eddie/Glioblastoma-WGS/WGS
ALIGNMENTS=$WGS/alignments
PARAMS=$WGS/params
SOURCE=$WGS/raw/source
READS=$WGS/raw/reads
LANES=$WGS/raw/lanes
BCBIO_CONFIG=$BASE/bcbio/config
BCBIO_WORK=$BASE/bcbio/work
SCRIPTS=$BASE/scripts ## needs cleaning
RESOURCES=$BASE/resources
METRICS=$WGS/metrics
PON=$METRICS/pon
QC=$WGS/qc
READ_BIAS=$QC/read_orientation_bias
CONT_DIR=$QC/calculate_contamination
VERIFYBAMID_DIR=$QC/verifybamid2
GERMLINE_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/germline
GDB_DIR=$GERMLINE_DIR/gdb

## Variants:
BCBIO_VARIANTS=$WGS/variants/bcbio
SSV=$WGS/variants/ssv
VARIANTS=$WGS/variants
M2_VARIANTS_UNFILTERED=$SSV/samples/Mutect2/unfiltered
M2_VARIANTS_FILTERED=$SSV/samples/Mutect2/filtered
M2_VARIANTS_PASSED=$SSV/samples/Mutect2/passed
M2_VARIANTS_FORMATTED=$SSV/samples/Mutect2/formatted_vcf
STRELKA2_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/bcbio/${STAGE}/${PATIENT_ID}/${PATIENT_ID}${TYPE}
S2_VARIANTS_PASSED=$SSV/samples/Strelka2/passed
S2_VARIANTS_OXOG=$SSV/samples/Strelka2/oxog_filtered
S2_VARIANTS_FORMATTED=$SSV/samples/Strelka2/formatted_vcf
VARDICT_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/bcbio/${STAGE}/${PATIENT_ID}/${PATIENT_ID}${TYPE}
VARDICT_VARIANTS_PASSED=$SSV/samples/Vardict/passed
VARDICT_VARIANTS_OXOG=$SSV/samples/Vardict/oxog_filtered
VARDICT_VARIANTS_FORMATTED=$SSV/samples/Vardict/formatted_vcf
INTERSECT_DIR=$SSV/intersect
M2_S2=$INTERSECT_DIR/M2_S2
M2_Var=$INTERSECT_DIR/M2_Var
S2_Var=$INTERSECT_DIR/S2_Var
CONSENSUS_DIR=$SSV/consensus
ENSEMBLE_DIR=$SSV/ensemble
ENSEMBLE_VCF=$ENSEMBLE_DIR/${STAGE}/${PATIENT_ID}${TYPE}.ssv.vcf.gz

WORK_DIR=$BCBIO_WORK/$PATIENT_ID
JVM_OPTS="-Dsamjdk.use_async_io_read_samtools=false -Dsamjdk.use_async_io_write_samtools=true -Dsamjdk.use_async_io_write_tribble=false -Dsamjdk.compression_level=1 -Xms12g -Xmx12g"
JVM_TMP_DIR="-Djava.io.tmpdir=$WORK_DIR"
JAVA=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/envs/snakemake/bin/java

GERMLINE_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/germline/
 
## Files:
BCBIO_ALIGNMENT_TEMPLATE=$BCBIO_CONFIG/templates/align.yaml
BCBIO_ALIGNMENT_TEMPLATE_TUMOUR_ONLY=$BCBIO_CONFIG/templates/align_tumour_only.yaml
BCBIO_ALIGNMENT_TEMPLATE_CHIP_SEQ=$BCBIO_CONFIG/templates/chipseq.yaml
BCBIO_VARIANT_TEMPLATE=$BCBIO_CONFIG/templates/variant.yaml
BCBIO_SVARIANT_TEMPLATE=$BCBIO_CONFIG/templates/svariant.yaml
BCBIO_ALIGNMENT_TEMPLATE_RNA_SEQ=$BCBIO_CONFIG/templates/rnaseq.yaml
TUMOR_DIR=$ALIGNMENTS/${PATIENT_ID}${TYPE}/${PATIENT_ID}${TYPE} 
NORMAL_DIR=$ALIGNMENTS/${PATIENT_ID}N/${PATIENT_ID}N
ALIGNED_BAM_FILE_TUMOR=$TUMOR_DIR/${PATIENT_ID}${TYPE}-ready.bam
ALIGNED_BAM_FILE_NORMAL=$NORMAL_DIR/${PATIENT_ID}N-ready.bam
ALIGNED_CRAM_FILE_TUMOR=$TUMOR_DIR/${PATIENT_ID}${TYPE}-ready.cram 
ALIGNED_CRAM_FILE_NORMAL=$NORMAL_DIR/${PATIENT_ID}N-ready.cram

## HMF JARs:
SAGE_JAR=/exports/igmm/eddie/Glioblastoma-WGS/scripts/hmftools-sage-v3.3/sage_v3.3.jar
AMBER_JAR=/exports/igmm/eddie/Glioblastoma-WGS/scripts/hmftools-amber-v3.9.1/amber-3.9.1.jar
COBALT_JAR=/exports/igmm/eddie/Glioblastoma-WGS/scripts/hmftools-cobalt-v1.15.2/cobalt_v1.15.2.jar
PURPLE_JAR=/exports/igmm/eddie/Glioblastoma-WGS/scripts/hmftools-purple-v3.9/purple_v3.9.jar

## Files:
SAGE_SOMATIC_VCF=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/ssv/sage/${STAGE}/${PATIENT_ID}${TYPE}/${PATIENT_ID}${TYPE}.sage.somatic.vcf.gz
SAGE_GERMLINE_VCF=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/ssv/sage/${STAGE}/${PATIENT_ID}${TYPE}/${PATIENT_ID}${TYPE}.sage.germline.vcf.gz
OUTPUT_AMBER=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/amber/${STAGE}
OUTPUT_COBALT=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/cobalt/${STAGE}
PURPLE_ANNOTATE_STRELKA_AD=/exports/igmm/eddie/Glioblastoma-WGS/scripts/hmftools-purple-v2.47/purity-ploidy-estimator/src/main/java/com/hartwig/hmftools/purple/tools/AnnotateStrelkaWithAllelicDepth.java
PURPLE_SNV_INPUT=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/ssv/ensemble/${PATIENT_ID}${TYPE}.ssv.snpeff.vcf.gz
##PURPLE_SNV_OUTPUT=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/purple/${STAGE}/${PATIENT_ID}${TYPE}/${PATIENT_ID}${TYPE}.purple.somatic.vcf.gz
PURPLE_SNV_OUTPUT=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/purple/v2/${STAGE}/${PATIENT_ID}${NEW_TYPE}/${PATIENT_ID}${TYPE}.purple.somatic.vcf.gz
PURPLE_SV_OUTPUT=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/purple/v2/${STAGE}/${PATIENT_ID}${NEW_TYPE}/${PATIENT_ID}${TYPE}.purple.sv.vcf.gz
##PURPLE_CNV_GENE_OUTPUT=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/purple/${STAGE}/${PATIENT_ID}${TYPE}/${PATIENT_ID}${TYPE}.purple.cnv.gene.tsv
PURPLE_CNV_GENE_OUTPUT=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/purple/v2/${STAGE}/${PATIENT_ID}${NEW_TYPE}/${PATIENT_ID}${TYPE}.purple.cnv.gene.tsv
OUTPUT_PURPLE=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/purple/${STAGE}
CIRCOS=/exports/igmm/eddie/Glioblastoma-WGS/scripts/circos-0.69-9/bin/circos

## Version 5.33:
HMF_RESOURCES_V533=$RESOURCES/hmf_dna_pipeline_resources.38_v5.33
HMF_ENSEMBLE_V533=$HMF_RESOURCES_V533/common/ensembl_data
SOMATIC_HOTSPOTS_V533=$HMF_RESOURCES_V533/variants/KnownHotspots.somatic.38.vcf.gz
GERMLINE_HOTSPOTS_V533=$HMF_RESOURCES_V533/variants/KnownHotspots.germline.38.vcf.gz
ACTIONABLE_V533=$HMF_RESOURCES_V533/variants/ActionableCodingPanel.38.bed.gz
HIGH_CONF_BED_V533=$HMF_RESOURCES_V533/variants/HG001_GRCh38_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM1-X_v.3.3.2_highconf_nosomaticdel_noCENorHET7.bed.gz
COVERAGE_PANEL_BED=$HMF_RESOURCES_V533/variants/CoverageCodingPanel.38.bed.gz
GERMLINE_BLACKLIST_VCF=$HMF_RESOURCES_V533/variants/KnownBlacklist.germline.38.vcf.gz
GERMLINE_BLACKLIST_BED=$HMF_RESOURCES_V533/variants/KnownBlacklist.germline.38.bed
TUMOR_ONLY_DIPLOID_BED=$HMF_RESOURCES_V533/copy_number/DiploidRegions.38.bed.gz
GERMLINE_HET_PON=$HMF_RESOURCES_V533/copy_number/GermlineHetPon.38.vcf.gz
GC_PROFILE=$HMF_RESOURCES_V533/copy_number/GC_profile.1000bp.38.cnp
GRIPSS_FUSION=$HMF_RESOURCES_V533/known_fusions.38.bedpe

## Other resources:
FRAGILE_SITES=/exports/igmm/eddie/Glioblastoma-WGS/resources/HMFTools-Resources/Linx/fragile_sites_hmf.hg38.csv
LINE_ELEMENTS=/exports/igmm/eddie/Glioblastoma-WGS/resources/HMFTools-Resources/Linx/line_elements.hg38.csv
HELI_REP_ORIGIN=/exports/igmm/eddie/Glioblastoma-WGS/resources/HMFTools-Resources/Linx/heli_rep_origins.bed
VIRAL_HOST_REF=/exports/igmm/eddie/Glioblastoma-WGS/resources/HMFTools-Resources/Linx/viral_host_ref.csv
###HMF_FUSION=/exports/igmm/eddie/Glioblastoma-WGS/resources/HMFTools-Resources/Linx/known_fusion_data.csv  

## GRIDSS and GRIPSS:
GRIDSS=$SCRIPTS/gridss-2.10.0/scripts/gridss.sh
GRIDSS_JAR=$SCRIPTS/gridss-2.10.0/gridss-2.10.0-gridss-jar-with-dependencies.jar
GRIDSS_RM=$SCRIPTS/gridss-2.10.0/scripts/gridss_annotate_vcf_repeatmasker.sh
GRIDSS_SOMATIC_FILTER=$SCRIPTS/gridss-2.10.0/scripts/gridss_somatic_filter.R
GRIPSS_JAR=$SCRIPTS/hmftools-gripss-v1.7/gripss-1.7.jar

GRIDSS_DIR=${WGS}/variants/sv/gridss
GRIDSS_OUTPUT=$GRIDSS_DIR/results/${STAGE}
GRIDSS_WORKING_DIR=$GRIDSS_DIR/working_dir/${PATIENT_ID}${TYPE}
GRIDSS_RAW_VCF=$GRIDSS_OUTPUT/${PATIENT_ID}${TYPE}.gridss.raw.vcf
GRIDSS_ASSEMBLY=$GRIDSS_OUTPUT/${PATIENT_ID}${TYPE}.assembly.bam
GRIDSS_FINAL_FILTERED=$GRIDSS_OUTPUT/${PATIENT_ID}${TYPE}.gridss.final.filtered.vcf
GRIDSS_FINAL_FILTERED_RM=$GRIDSS_OUTPUT/${PATIENT_ID}${TYPE}.gridss.final.filtered.rm.vcf
GRIDSS_PON_FILTERED=$GRIDSS_OUTPUT/${PATIENT_ID}${TYPE}.gridss.pon.filtered.vcf
GRIDSS_PON_FILTERED_RM=$GRIDSS_OUTPUT/${PATIENT_ID}${TYPE}.gridss.pon.filtered.rm.vcf
GRIDSS_PON=$GRIDSS_DIR/pondir/${BATCH}
LIBGRIDSS=/exports/igmm/eddie/Glioblastoma-WGS/scripts/gridss
GRIDSS_PLOT_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/gridss/plotdir

### LINX_JAR=/exports/igmm/eddie/Glioblastoma-WGS/scripts/hmftools-sv-linx-v1.11/sv-linx_v1.11.jar
LINX_JAR=/exports/igmm/eddie/Glioblastoma-WGS/scripts/hmftools-linx-v1.20/linx_v1.20.jar

OUTPUT_LINX=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/sv/linx/${STAGE}

## AmpliconArchitect:
AI=/exports/igmm/eddie/Glioblastoma-WGS/scripts/AmpliconArchitect/src/amplified_intervals.py
AA=/exports/igmm/eddie/Glioblastoma-WGS/scripts/AmpliconArchitect/src/AmpliconArchitect.py
PURPLE_TMP_DIR=$VARIANTS/ecdna/PURPLE_TMP/${SAMPLE_ID}
PURPLE_TMP_CNV=$PURPLE_TMP_DIR/${SAMPLE_ID}.purple.cnv.somatic.tsv ## from PURPLE
AA_PURPLE_CN_DIR=$VARIANTS/ecdna/AA_PURPLE_CN
AI_CNV=$AA_PURPLE_CN_DIR/${SAMPLE_ID}.CN_AA.bed
AA_PURPLE_BED_DIR=$VARIANTS/ecdna/AA_PURPLE_BED
AA_CNV=$AA_PURPLE_BED_DIR/${SAMPLE_ID}.bed
AA_RESULTS_DIR=$VARIANTS/ecdna/AA_PURPLE_RESULTS
AC=/exports/igmm/eddie/Glioblastoma-WGS/scripts/AmpliconClassifier/amplicon_classifier.py
AA_CLASSIFIER_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/ecdna/AA_classifier/AC_v0.4.10/${STAGE}

## LILAC:
REF_NO_ALT=$RESOURCES/refgenome38/hg38_no_alt/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna.gz
####LILAC_JAR=$BASE/scripts/hmftools-lilac-v1.2/lilac_v1.2.jar
LILAC_JAR=$BASE/scripts/hmftools-lilac-v1.3_rc1/lilac_v1.3_rc1.jar
LILAC_RESOURCES=$RESOURCES/lilac
LILAC_OUTPUT=$VARIANTS/lilac/output
LILAC_INPUT=$VARIANTS/lilac/input

SLICED_BAM_DIR=$LILAC_INPUT
SLICED_BAM_NORMAL=$LILAC_INPUT/${PATIENT_ID}${NEW_TYPE}.germline.hla_sliced.bam
SLICED_BAM_NORMAL_REALIGNED=$LILAC_INPUT/${PATIENT_ID}${NEW_TYPE}.germline.hla_sliced_realigned_to_no_alt.bam
###SLICED_BAM_NORMAL_REALIGNED_HLA_SUBSET=$LILAC_INPUT/${PATIENT_ID}${NEW_TYPE}.germline.hla_sliced_realigned_to_no_alt_HLA_subset.bam
SLICED_BAM_TUMOR=$LILAC_INPUT/${PATIENT_ID}${NEW_TYPE}.tumour.hla_sliced.bam
SLICED_BAM_TUMOR_REALIGNED=$LILAC_INPUT/${PATIENT_ID}${NEW_TYPE}.tumour.hla_sliced_realigned_to_no_alt.bam
###SLICED_BAM_TUMOR_REALIGNED_HLA_SUBSET=$LILAC_INPUT/${PATIENT_ID}${NEW_TYPE}.tumour.hla_sliced_realigned_to_no_alt_HLA_subset.bam

## Misc:
MSISENSOR=/exports/igmm/eddie/Glioblastoma-WGS/anaconda/bin/msisensor
MSI_DIR=/exports/igmm/eddie/Glioblastoma-WGS/WGS/variants/MSI
GATK4=/exports/igmm/software/pkg/el7/apps/bcbio/1.1.5/share/anaconda/share/gatk4-4.1.4.1-1/gatk
GATK4_BIN=$GATK4
GATK4_JAR=/gpfs/igmmfs01/software/pkg/el7/apps/bcbio/1.1.5/share/anaconda/share/gatk4-4.1.4.1-1/gatk-package-4.1.4.1-local.jar
PICARD_JAR=/exports/igmm/software/pkg/el7/apps/bcbio/1.2.0/anaconda/share/picard-2.23.8-0/picard.jar
REPEAT_MASKER_EXE=/exports/igmm/eddie/Glioblastoma-WGS/resources/RepeatMasker/RepeatMasker
ENCODE_BLACKLIST=$RESOURCES/encode4_GRCh38_blacklist.bed.gz
REPEAT_MASKER=$RESOURCES/hg38.fa.out.bed
BLACKLISTED_PEAKS=/exports/igmm/eddie/Glioblastoma-WGS/resources/hg38-blacklist.v2.bed
BLACKLISTED_PEAKS_MM10=/exports/igmm/eddie/Glioblastoma-WGS/resources/mm10-blacklist.v2.bed.gz
BOWTIE_REF=$RESOURCES/refgenome38/hg38
BWA_REF=$RESOURCES/refgenome38/hg38.fa
REFERENCE=$RESOURCES/refgenome38/hg38.fa
REFERENCE_DICT=$RESOURCES/refgenome38/hg38.dict
REFERENCE_HG37=$RESOURCES/refgenome37/Homo_sapiens.GRCh37.dna.primary_assembly.fa
REFERENCE_DICT_HG37=$RESOURCES/refgenome37/Homo_sapiens.GRCh37.dna.primary_assembly.dict
KNOWN_SITES=/exports/igmm/eddie/NextGenResources/bcbio-1.1.5/genomes/Hsapiens/hg38/variation/dbsnp-151.vcf.gz
KNOWN_GATK_SITES=$RESOURCES/Mutect2_resources/small_exac_common_3.hg38.vcf.gz
GATK_AF_GNOMAD=$RESOURCES/Mutect2_resources/af-only-gnomad.hg38.vcf.gz
INTERVAL_LIST=$RESOURCES/Mutect2_resources/wgs_calling_regions.hg38.interval_list
INTERVAL_LIST_CNV_COMMON_SITES=$CNV/interval_list/cnv_somatic_somatic-hg38_af-only-gnomad.hg38.AFgt0.02.interval_list
FUNCOTATOR_DIR=$RESOURCES/Mutect2_resources/funcotator_dataSources.v1.6.20190124s
CHAIN38TO37=/exports/igmm/eddie/Glioblastoma-WGS/resources/liftover/hg38ToHg19.over.chain
CHAIN19TO38=/exports/igmm/eddie/Glioblastoma-WGS/resources/liftover/hg19ToHg38.over.chain
VIRAL_GENOME=/exports/igmm/eddie/Glioblastoma-WGS/resources/viralgenome/human_virus.fa
SNPEFF_JAR=/exports/igmm/eddie/Glioblastoma-WGS/resources/snpEff/snpEff.jar
HG38_CHROM_SIZE=/exports/igmm/eddie/Glioblastoma-WGS/resources/hg38.chrom.sizes
GISTIC2_DIR=/exports/igmm/eddie/Glioblastoma-WGS/scripts/GISTIC2
GISTIC2=$GISTIC2_DIR/gistic2
GISTICREF=$GISTIC2_DIR/refgenefiles/hg38.UCSC.add_miR.160920.refgene.mat


