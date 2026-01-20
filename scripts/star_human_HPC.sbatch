#!/bin/bash
#SBATCH --job-name=start_human
#SBATCH --mail-user=Isabel.FernandezEscapa@bcm.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=24:00:00
#SBATCH --error=logs/%x_%A_%a.err
#SBATCH --output=logs/%x_%A_%a.out

### enable 'module' commands
source /etc/profile.d/lmod.sh

### Load STAR module
module load star/2.7.10b

### Define paths
PROJECT_PATH=$1
RAW_DATA_PATH=$2
GENOME_INDEX=$3

OUTPUT_DIR="${PROJECT_PATH}/star_human"
mkdir -p "$OUTPUT_DIR"
TEMP_PATH="${PROJECT_PATH}/temp_transfer/star_human"
mkdir -p "${TEMP_PATH}"

### Get the sample name based on SLURM_ARRAY_TASK_ID
SAMPLE=$(ls $RAW_DATA_PATH/*_R1_001.fastq.gz | sort | sed -n "${SLURM_ARRAY_TASK_ID}p" | xargs -n 1 basename | sed 's/_R1_001.fastq.gz//')

### Define input files
R1="$RAW_DATA_PATH/${SAMPLE}_R1_001.fastq.gz"
R2="$RAW_DATA_PATH/${SAMPLE}_R2_001.fastq.gz"

### Print task info
echo "Running task $SLURM_ARRAY_TASK_ID for sample $SAMPLE"
echo "FASTQ files: $R1, $R2"
echo "Genome Index: $GENOME_INDEX"
echo "Output Directory: $OUTPUT_DIR"

### Run STAR
STAR --runThreadN 8 \
     --genomeDir "$GENOME_INDEX" \
     --readFilesIn "$R1" "$R2" \
     --readFilesCommand gunzip -c \
     --outFileNamePrefix "$OUTPUT_DIR/${SAMPLE}_" \
     --quantMode TranscriptomeSAM GeneCounts \
     --outSAMtype None
     --outReadsUnmapped Fastx \
     --limitBAMsortRAM 45000000000
     
### Copy FILES into temp_transfer
cp "${PROJECT_PATH}/star_human/${SAMPLE}_Log.final.out" "$TEMP_PATH/"
cp "${PROJECT_PATH}/star_human/${SAMPLE}_ReadsPerGene.out.tab" "$TEMP_PATH/"
cp "${PROJECT_PATH}/star_human/${SAMPLE}_SJ.out.tab" "$TEMP_PATH/"




     