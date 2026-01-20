#!/bin/bash
#SBATCH --job-name=rsem_human
#SBATCH --mail-user=Isabel.FernandezEscapa@bcm.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --error=logs/%x_%A_%a.err
#SBATCH --output=logs/%x_%A_%a.out

### enable 'module' commands
source /etc/profile.d/lmod.sh

### Load modules
module load perl/5.40.0
module load rsem/1.3.3
module load samtools/1.17

### Define paths
PROJECT_PATH=$1
SUBSAMPLE_FOLDER=$2
RSEM_INDEX=$3

OUTPUT_DIR="${PROJECT_PATH}/rsem_human_subsampled"
mkdir -p "$OUTPUT_DIR"
TEMP_PATH="${PROJECT_PATH}/temp_transfer/rsem_human_subsampled"
mkdir -p "${TEMP_PATH}"

### Get the sample name based on SLURM_ARRAY_TASK_ID
SAMPLE=$(ls $SUBSAMPLE_FOLDER/*_subsampled.bam | sort | sed -n "${SLURM_ARRAY_TASK_ID}p" | xargs -n 1 basename | sed 's/_subsampled.bam//')

### Define input file
INPUT_BAM="$SUBSAMPLE_FOLDER/${SAMPLE}_subsampled.bam"

### Print task info
echo "Running task $SLURM_ARRAY_TASK_ID for sample $SAMPLE"
echo "Input BAM file: $INPUT_BAM"
echo "RSEM Index: $RSEM_INDEX"
echo "Output Directory: $OUTPUT_DIR"

### Run RSEM
rsem-calculate-expression --alignments --paired-end \
    --estimate-rspd \
    --no-bam-output \
    --num-threads 8 \
    "$INPUT_BAM" "$RSEM_INDEX" "$OUTPUT_DIR/${SAMPLE}"
    
### Copy FILES into temp_transfer
cp "${PROJECT_PATH}/rsem_human_subsampled/${SAMPLE}.genes.results" "$TEMP_PATH/"
cp "${PROJECT_PATH}/rsem_human_subsampled/${SAMPLE}.isoforms.results" "$TEMP_PATH/"

