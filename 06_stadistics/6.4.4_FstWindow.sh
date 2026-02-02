#!/bin/bash
#SBATCH --job-name=windowFst
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=40
#SBATCH --time=168:00:00
#SBATCH --mem=100gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/FST_window/1kbstep/windowFst.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/FST_window/1kbstep/windowFst.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/FST_window/1kbstep/windowFst.log"
REALSFS="/home/edmonge/wgs_acrocomia/programs/angsd/misc/realSFS"
FSTINDEX="/home/edmonge/wgs_acrocomia/analyses/statistics/indexFst"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/FST_window/1kbstep"


for fst_idx in $FSTINDEX/*.fst.idx; do
    base=$(basename "$fst_idx" .fst.idx)
    echo "Starting 15kb window FST for $base at $(date)" >> "$LOG"

    $REALSFS fst stats2 "$fst_idx" \
        -win 15000 -step 1000 -whichFst 1 -P 40 \
        > "$OUTDIR/${base}_15kb_1kbstep.txt"

    echo "Finished 15kb window FST for $base at $(date)" >> "$LOG"
done

echo "All 15kb window FST calculations completed at $(date)" >> "$LOG"
