#!/bin/bash
#SBATCH --job-name=safHet
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=10
#SBATCH --time=168:00:00
#SBATCH --mem=200gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/het/dosaf_het.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/het/dosaf_het.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/het/dosaf_het.log"
ANGSD="/home/edmonge/wgs_acrocomia/programs/angsd/angsd"
SAMPLES="/home/edmonge/wgs_acrocomia/samples_final85"
BAM="/home/edmonge/wgs_acrocomia/aligment_clip_20"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/het/samples"
GENOMA="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"
SITES="/home/edmonge/wgs_acrocomia/analyses/statistics/het"

while read -r sample; do
  echo "Starting doSaf for: $sample in $(date)" >> "$LOG"

  $ANGSD -i $BAM/${sample}.clip.bam \
    -ref $GENOMA \
    -anc $GENOMA \
    -sites $SITES/global.pos \
    -out $OUTDIR/${sample} \
    -uniqueOnly 1 \
    -remove_bads 1 \
    -only_proper_pairs 1 \
    -C 50 \
    -baq 1 \
    -minMapQ 20 \
    -minQ 20 \
    -P 10 \
    -GL 1 \
    -doSaf 1

  echo "Finished doSaf for: $sample in $(date)" >> "$LOG"
done < $SAMPLES
