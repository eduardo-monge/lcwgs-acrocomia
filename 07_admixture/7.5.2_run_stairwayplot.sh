#!/bin/bash
#SBATCH --job-name=run_rav
#SBATCH --partition=bigmem
#SBATCH --array=0-7
#SBATCH --ntasks-per-node=4
#SBATCH --time=168:00:00
#SBATCH --mem=100gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/revbayes/logs/02_run_%A_%a.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/revbayes/logs/02_run_%A_%a.log

WORKDIR="/home/edmonge/wgs_acrocomia/analyses/revbayes"
RAV="/home/edmonge/wgs_acrocomia/programs/revbayes/bin/rb"
POPS=(Amazonas Costarican Intumescens Mesoamerica Mineiro Roraima Sudeste Totai)
POP=${POPS[$SLURM_ARRAY_TASK_ID]}

echo "Starting Bayesian StairwayPlot for: $POP"
echo "Start time: $(date)"

cd "$WORKDIR"
mkdir -p logs output/$POP

$RAV -e "POP_NAME = \"${POP}\"; source(\"/home/edmonge/wgs_acrocomia/slurm_scripts/revbayes/stairwayplot_2.Rev\")"

echo "Finished: $POP at $(date)"
