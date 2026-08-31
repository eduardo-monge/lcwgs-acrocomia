#!/bin/bash
#SBATCH --job-name=boot_estim2
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00
#SBATCH --mem=20gb
#SBATCH --array=1-1000%15
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/bootstrap/logs/02_estim_b2_%a.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/bootstrap/logs/02_estim_b2_%a.log

set -euo pipefail

FSC2="/home/edmonge/wgs_acrocomia/programs/fsc28_linux64/fsc28"
BOOT_DIR="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/bootstrap"
SIM_DIR="$BOOT_DIR/01_simulated_sfs"
EST_BASE="$BOOT_DIR/02_estimation"
MODEL_DIR="/home/edmonge/wgs_acrocomia/slurm_scripts/fastsimcoal2/Test1_Roraima/Model1b"

RUNS_PER_REP=20
OFFSET=1000 #To run all the replicated. Based on the limits of the server

TASK=$(( SLURM_ARRAY_TASK_ID + OFFSET ))
BOOT_REP=$(( (TASK - 1) / RUNS_PER_REP + 1 ))
RUN=$(( (TASK - 1) % RUNS_PER_REP + 1 ))

# Source bootstrap SFS file
SRC_SFS="$SIM_DIR/Model1b_boot/Model1b_boot_${BOOT_REP}/Model1b_boot_MSFS.obs"

# Destination
WORK_DIR="$EST_BASE/boot_${BOOT_REP}/run_${RUN}"

# Skip if already completed
if [[ -f "$WORK_DIR/Model1b/Model1b.bestlhoods" ]]; then
    echo "Task $TASK (boot=$BOOT_REP, run=$RUN) already done - skipping"
    exit 0
fi

# Verify source SFS exists
if [[ ! -f "$SRC_SFS" ]]; then
    echo "[ERROR] Source SFS not found: $SRC_SFS"
    exit 1
fi

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

cp "$MODEL_DIR/Model1b.tpl" .
cp "$MODEL_DIR/Model1b.est" .
cp "$SRC_SFS" "./Model1b_MSFS.obs"

SEED=$(( TASK * 1000 + RANDOM % 1000 ))

echo "Starting boot=$BOOT_REP run=$RUN (effective task=$TASK) at $(date), seed=$SEED"

$FSC2 \
  -t Model1b.tpl \
  -e Model1b.est \
  -n 500000 \
  -m \
  -M \
  -L 60 \
  -q \
  -c 8 \
  -B 0 \
  -r $SEED \
  --multiSFS

if [[ ! -f "Model1b/Model1b.bestlhoods" ]]; then
    echo "[ERROR] No bestlhoods file for boot=$BOOT_REP run=$RUN"
    exit 1
fi

echo "Finished boot=$BOOT_REP run=$RUN at $(date)"
