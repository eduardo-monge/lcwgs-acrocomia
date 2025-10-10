#!/bin/bash
#SBATCH --job-name=ohana
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=30
#SBATCH --time=168:00:00
#SBATCH --mem=100gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/Ohana/test/ohana.err
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/Ohana/test/ohana.out

OHANA="/home/edmonge/wgs_acrocomia/ohana/bin/qpas"
LGM="/home/edmonge/wgs_acrocomia/analyses/Ohana/Ohana.lgm"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/Ohana/test"

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
K_LIST=(4)
REPS=20
TASK_ID=${SLURM_ARRAY_TASK_ID}
K_INDEX=$(( TASK_ID / REPS ))
REP_INDEX=$(( TASK_ID % REPS + 1 ))
K=${K_LIST[$K_INDEX]}
LOGFILE="$OUTDIR/ohana_K${K}_rep${REP_INDEX}.log"

echo "START: K=$K, Rep=$REP_INDEX at $(date)" >> "$LOGFILE"
$OHANA $LGM \
    -k $K \
    -qo $OUTDIR/q${K}_rep${REP_INDEX}.matrix \
    -fo $OUTDIR/f${K}_rep${REP_INDEX}.matrix \
    -mi 30 \
    -s $RANDOM \
    >> "$LOGFILE" 2>&1

echo "FINISHED: K=$K, Rep=$REP_INDEX at $(date)" >> "$LOGFILE"
