#!/bin/bash
#SBATCH --job-name=ByPass
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=10
#SBATCH --time=168:00:00
#SBATCH --mem=200gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/06_ByPass_large.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/06_ByPass_large.log

LOG="/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/06_ByPass_large.log"
POD="/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/G.acrocomia_pod_large"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass"
BAYPASS="/home/edmonge/wgs_acrocomia/programs/BayPass/sources/g_baypass"

echo "Started: $(date)" >> "$LOG"

$BAYPASS \
  -gfile $POD \
  -nval 10000 -thin 20 -burnin 5000 \
  -npilot 20 -pilotlength 500 \
  -nthreads 8 -seed 5001 \
  -outprefix $OUTDIR/pod_calib_large

echo "Finished: $(date)" >> "$LOG"
