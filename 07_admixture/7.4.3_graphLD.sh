#!/bin/bash
#SBATCH --job-name=ldgraph
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=10
#SBATCH --time=168:00:00
#SBATCH --mem=800gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/LD_Decay/LD_Pops/Graph.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/LD_Decay/LD_Pops/Graph.log

export LD_LIBRARY_PATH=$HOME/miniconda3/lib:$LD_LIBRARY_PATH
export PATH=$HOME/wgs_acrocomia/ngsLD:$PATH

RSCRIP="/home/edmonge/wgs_acrocomia/programs/ngsLD/scripts/fit_LDdecay_mine.R"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/LD_Decay/LD_Pops"
LIST="/home/edmonge/wgs_acrocomia/analyses/LD_Decay/LD_Pops/ld_pops.list"
LOG="/home/edmonge/wgs_acrocomia/analyses/LD_Decay/LD_Pops/Graph.log"

echo "Starting LD decay analysis at $(date)" > "$LOG"
Rscript --vanilla $RSCRIP \
  --ld_files $LIST \
  --header \
  --col 3 \
  --ld r2 \
  --max_kb_dist 1000 \
  --fit_level 10 \
  --fit_bin_size 1000 \
  --plot_data \
  --plot_bin_size 1000 \
  --plot_x_lim 1000 \
  --plot_y_lim 0.8 \
  --plot_wrap 4 \
  --plot_size 12,12 \
  --plot_scale 1 \
  --out $OUTDIR/LD_decay_full.pdf >> "$LOG" 2>&1

echo "Finished LD decay at $(date)"  >> "$LOG"
