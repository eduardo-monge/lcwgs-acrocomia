#!/bin/bash
#SBATCH --job-name=bp_gea_is
#SBATCH --partition=bigmem
#SBATCH --array=1-180%10
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/GEA/logs/gea_%a_%j.log
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/GEA/logs/gea_%a_%j.log
#SBATCH --time=72:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --ntasks=1

BASE=/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass
CHUNKDIR=$BASE/chunks
COVDIR=$BASE/covfiles
GEADIR=$BASE/GEA
BAYPASS=/home/edmonge/wgs_acrocomia/programs/BayPass/sources/g_baypass

ID=$(printf "%04d" $SLURM_ARRAY_TASK_ID)
GL=$CHUNKDIR/acrocomia_sub${ID}.gl
OMEGA=$CHUNKDIR/core_sub${ID}_seed5001_mat_omega.out

cd $GEADIR
echo "Started chunk $ID: $(date)"

$BAYPASS \
  -gldatafile $GL \
  -efile $COVDIR/env_all.cov \
  -omegafile $OMEGA \
  -nval 10000 -thin 20 -burnin 5000 \
  -npilot 20 -pilotlength 500 \
  -nthreads 8 -seed 5001 \
  -outprefix $GEADIR/gea_sub${ID}

echo "End chunk $ID: $(date)"
