#!/bin/bash
#SBATCH --job-name=fsc2_intu
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=8
#SBATCH --time=48:00:00
#SBATCH --mem=20gb
#SBATCH --array=1-300%20
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test2_Intumescens/logs/fsc2_%x_%a.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test2_Intumescens/logs/fsc2_%x_%a.log

if [ -z "$MODEL" ]; then
  echo "ERROR: MODEL not set. Submit via submit_all.sh, not directly." >&2
  exit 1
fi

FSC2="/home/edmonge/wgs_acrocomia/programs/fsc28_linux64/fsc28"
MODEL_DIR="/home/edmonge/wgs_acrocomia/slurm_scripts/fastsimcoal2/Test2_Intumescens/${MODEL}"
RUN_DIR="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test2_Intumescens/${MODEL}/run_${SLURM_ARRAY_TASK_ID}"

mkdir -p "$RUN_DIR"
cp "$MODEL_DIR/${MODEL}.tpl"      "$RUN_DIR/" || { echo "missing ${MODEL}.tpl"; exit 1; }
cp "$MODEL_DIR/${MODEL}.est"      "$RUN_DIR/" || { echo "missing ${MODEL}.est"; exit 1; }
cp "$MODEL_DIR/${MODEL}_MSFS.obs" "$RUN_DIR/" || { echo "missing ${MODEL}_MSFS.obs"; exit 1; }
cd "$RUN_DIR" || exit 1

echo "Starting ${MODEL}, replicate ${SLURM_ARRAY_TASK_ID} at $(date)"
$FSC2 \
  -t "${MODEL}.tpl" \
  -e "${MODEL}.est" \
  -n 500000 \
  -m \
  -M \
  -L 60 \
  -q \
  -c 8 \
  -B 0 \
  --multiSFS
echo "Finished ${MODEL}, replicate ${SLURM_ARRAY_TASK_ID} at $(date)"
