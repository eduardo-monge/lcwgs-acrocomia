#!/bin/bash
#SBATCH --job-name=ohana
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=168:00:00
#SBATCH --mem=200gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/outliers/ohana/03_f_new.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/outliers/ohana/03_f_new.log

LOG="/home/edmonge/wgs_acrocomia/analyses/outliers/ohana/03_f_new.log"
OHANA="/home/edmonge/wgs_acrocomia/programs/ohana/bin/qpas"
LGM="/home/edmonge/wgs_acrocomia/analyses/outliers/ohana/Ohana_full.lgm"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/outliers/ohana"
QMATRIX_DIR="/home/edmonge/wgs_acrocomia/analyses/Ohana/qmatrix"

echo "Doing f matrix at $(date)" >> "$LOG"

$OHANA $LGM \
    -k 8 \
    -qi $QMATRIX_DIR/q8_rep18.matrix \
    -fo $OUTDIR/full_f8.matrix \
    -fq \
    -mi 30 \
    -s $RANDOM \
    >> "$LOG" 2>&1

echo "FINISHED at $(date)" >> "$LOG"
