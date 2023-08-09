#!/bin/bash

#$ -N SAGE
#$ -j y
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=16G
#$ -pe sharedmem 16
#$ -l h_rt=48:00:00

CONFIG=$1
IDS=$2
RUN_TYPE=$3

PATIENT_ID=`head -n $SGE_TASK_ID $IDS | tail -n 1`

source $CONFIG

### Based on https://github.com/hartwigmedical/hmftools/blob/master/sage/README.md
### Can be run in tumour-only mode. 

# Check if the RUN_TYPE variable is set
if [ -z "$RUN_TYPE" ]; then
  echo "Error: The RUN_TYPE variable is not set."
  exit 1
fi

# Check the value of the RUN_TYPE variable
case "$RUN_TYPE" in
  "paired")
    echo "Running in tumour-normal mode..."
    echo $PATIENT_ID
    ;;
  "unpaired")
    echo "Running in tumour-only mode..."
    echo $PATIENT_ID
    ;;
  *)
    echo "Error: Invalid value for RUN_TYPE variable."
    exit 1
    ;;
esac