#!/bin/bash
#SBATCH --job-name=selection_ohana
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=168:00:00
#SBATCH --mem=200gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/outliers/ohana/04_selection.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/outliers/ohana/04_selection.log

SELSCAN="/home/edmonge/wgs_acrocomia/programs/ohana/bin/selscan"
LOG="/home/edmonge/wgs_acrocomia/analyses/outliers/ohana/04_selection.log"
LGM="/home/edmonge/wgs_acrocomia/analyses/outliers/ohana/Ohana_full.lgm"
FMATRIX="/home/edmonge/wgs_acrocomia/analyses/outliers/ohana/full_f8.matrix"
COMATRIX="/home/edmonge/wgs_acrocomia/analyses/Ohana/NJ/8_covariance.matrix"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/outliers/ohana"

echo "Running selection analysis for K=8 at $(date)" >> "$LOG"

$SELSCAN \
    $LGM \
    $FMATRIX \
    $COMATRIX \
    > $OUTDIR/selscan_K8.txt

echo "Selection analysis complete at $(date)" >> "$LOG"
