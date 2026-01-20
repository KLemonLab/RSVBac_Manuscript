#!/bin/bash
#SBATCH --job-name=bam_counts
#SBATCH --mail-user=Isabel.FernandezEscapa@bcm.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=05:00:00
#SBATCH --error=logs/%x_%A.err
#SBATCH --output=logs/%x_%A.out

### Enable 'module' commands
source /etc/profile.d/lmod.sh

### Load samtools
module load samtools/1.17

### Get project path from command line
PROJECT_PATH=$1
BAM_FOLDER="${PROJECT_PATH}/star_human"
SUBSAMPLE_FOLDER="${PROJECT_PATH}/subsampling"

### Make output folder
mkdir -p "$SUBSAMPLE_FOLDER"

### Output TSV path
OUTPUT_TSV="${SUBSAMPLE_FOLDER}/bam_read_counts.tsv"
echo -e "file\ttotal_reads\tmapped_reads" > "$OUTPUT_TSV"

### Loop through BAM files and count reads
for f in "$BAM_FOLDER"/*_Aligned.toTranscriptome.out.bam; do
  total=$(samtools view -c "$f")
  mapped=$(samtools view -c -F 4 "$f")
  echo -e "$(basename "$f")\t$total\t$mapped" >> "$OUTPUT_TSV"
done

### Sort by total_reads
sort -k2 -n "$OUTPUT_TSV" -o "$OUTPUT_TSV"