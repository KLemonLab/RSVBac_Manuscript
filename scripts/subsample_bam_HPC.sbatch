#!/bin/bash
#SBATCH --job-name=subsample_bam
#SBATCH --mail-user=Isabel.FernandezEscapa@bcm.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=10:00:00
#SBATCH --error=logs/%x_%A_%a.err
#SBATCH --output=logs/%x_%A_%a.out

### enable 'module' commands
source /etc/profile.d/lmod.sh

### Load modules
module load samtools/1.17

### Define paths
PROJECT_PATH=$1
BAM_FOLDER=$2
TARGET_DEPTH=$3 

OUT_FOLDER="${PROJECT_PATH}/subsampling"
mkdir -p "$OUT_FOLDER"

### Get the sample name based on SLURM_ARRAY_TASK_ID
SAMPLE=$(ls "$BAM_FOLDER"/*_Aligned.toTranscriptome.out.bam | sort | sed -n "${SLURM_ARRAY_TASK_ID}p")
BASENAME=$(basename "$SAMPLE" _Aligned.toTranscriptome.out.bam)

### Output BAM file
OUTPUT_BAM="${OUT_FOLDER}/${BASENAME}_subsampled.bam"

### Count total reads
TOTAL_READS=$(samtools view -c "$SAMPLE")

### Calculate sampling fraction
FRACTION=$(echo "$TARGET_DEPTH / $TOTAL_READS" | bc -l)

### Check if sampling fraction exceeds 1
if (( $(echo "$FRACTION > 1" | bc -l) )); then
  echo "[$BASENAME] Skipping: target depth ($TARGET_DEPTH) > total reads ($TOTAL_READS)"
  exit 0
fi

### Format -s argument
SAMPLING_SEED="42"
FRACTION_PART=$(echo "$FRACTION" | cut -d'.' -f2 | cut -c1-8 | sed 's/^$/0/')
SAMPLING_ARG="${SAMPLING_SEED}.${FRACTION_PART}"

### Logging
echo "Sample: $BASENAME"
echo "Input BAM: $SAMPLE"
echo "Total Reads: $TOTAL_READS"
echo "Target Depth: $TARGET_DEPTH"
echo "Sampling Fraction: $FRACTION"
echo "Formatted -s argument: $SAMPLING_ARG"
echo "Output BAM: $OUTPUT_BAM"

### Run subsampling
samtools view -s "$SAMPLING_ARG" -b "$SAMPLE" > "$OUTPUT_BAM"