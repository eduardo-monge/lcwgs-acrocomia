#!/bin/bash
#SBATCH --job-name=bp_core
#SBATCH --partition=bigmem
#SBATCH --array=1-180%10
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/chunks/logs/core_%a_%j.log
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/chunks/logs/core_%a_%j.log
#SBATCH --time=48:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=8
#SBATCH --ntasks=1

CHUNKDIR="/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/chunks"
BAYPASS="/home/edmonge/wgs_acrocomia/programs/BayPass/sources/g_baypass"

ID=$(printf "%04d" $SLURM_ARRAY_TASK_ID)
GL=$CHUNKDIR/acrocomia_sub${ID}.gl

cd $CHUNKDIR

for SEED in 5001 6002 7003; do
  $BAYPASS \
    -gldatafile $GL \
    -nval 10000 -thin 20 -burnin 5000 \
    -npilot 20 -pilotlength 500 \
    -nthreads 8 \
    -seed $SEED \
    -outprefix core_sub${ID}_seed${SEED}
done
