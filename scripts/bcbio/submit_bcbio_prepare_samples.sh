#!/bin/bash
# Adapted from Alison Meynert

# To run this script, do 
# qsub -t 1-n submit_bcbio_prepare_samples.sh CONFIG IDS DATE BATCH
#
# CONFIG is the path to the file scripts/config.sh which contains environment variables set to
# commonly used paths and files in the script

# IDS is a list of sample ids, one per line, where tumor and normal samples are designated by
# the addition of a T or an N to the sample id.

# DATE is the batch date for the group of samples

# BATCH is the batch name, e.g. TCGA, Peng etc.
#
#$ -N bcbio_prepare_samples
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=4G
#$ -l h_rt=72:00:00
#$ -pe sharedmem 4

CONFIG=$1
IDS=$2
DATE=$3
BATCH=$4

source $CONFIG

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1 | cut -f 1`

# Create the prepare_samples.csv file

echo $PATIENT_ID

cd $BCBIO_CONFIG
echo "samplename,description,phenotype" > ${PATIENT_ID}_prepare_samples.csv
for file in `ls $SOURCE/${BATCH}/fastqs/${PATIENT_ID}_L/*.gz`
do
    echo "$file,${PATIENT_ID}N,normal" >> ${PATIENT_ID}_prepare_samples.csv
done
    
for file in `ls $SOURCE/${BATCH}/fastqs/${PATIENT_ID}/*.gz`
do
    echo "$file,${PATIENT_ID}T,tumor" >> ${PATIENT_ID}_prepare_samples.csv
done

# Group the FASTQ files by sample
# This will create a symlink
bcbio_prepare_samples.py --out $READS --csv ${PATIENT_ID}_prepare_samples.csv

# Create the YAML template
bcbio_nextgen.py -w template $BCBIO_ALIGNMENT_TEMPLATE ${PATIENT_ID}_prepare_samples-merged.csv $READS/${PATIENT_ID}*.fastq.gz

# Split the configuration YAML file by sample
perl $SCRIPTS/split_bcbio_config_by_sample.pl --input ${PATIENT_ID}_prepare_samples-merged/config/${PATIENT_ID}_prepare_samples-merged.yaml --output . --upload $ALIGNMENTS --type alignment --fc_date $DATE --fc_name $BATCH

# Clean up the intermediate files
rm -r ${PATIENT_ID}_prepare_samples-merged






