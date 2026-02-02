#!/bin/bash
#SBATCH --job-name=calc_het
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=10
#SBATCH --time=168:00:00
#SBATCH --mem=200gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/het/calchet.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/het/calchet.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/het/calchet.log"
REALSFS="/home/edmonge/wgs_acrocomia/programs/angsd/misc/realSFS"
SAF="/home/edmonge/wgs_acrocomia/analyses/statistics/het/samples"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/het/samples"
OUTDIRHET="/home/edmonge/wgs_acrocomia/analyses/statistics/het/final_het"
SAMPLES="/home/edmonge/wgs_acrocomia/samples_final85"

while read -r sample; do
        #1-Real SFS
  echo "Starting Real SFS for: $POP in $(date)" >> "$LOG"
        $REALSFS $SAF/${sample}.saf.idx \
        -P 10 \
        -fold 1 \
        >$OUTDIR/${sample}.het
  echo "Finished do Real SFS for: $POP in $(date)" >> "$LOG"


#2-Calculate HET
  echo "Calculating Ho for $sample in $(date)" >> "$LOG"

  awk '{Ho = $2 / ($1 + $2 + $3); print "'$sample'\t"Ho}' \
    $OUTDIR/${sample}.het > $OUTDIRHET/${sample}.finalHet.txt

  echo "Finished calculating Ho for $sample in $(date)" >> "$LOG"
done < $SAMPLES

echo "Finished all samples in $(date)" >> "$LOG"
