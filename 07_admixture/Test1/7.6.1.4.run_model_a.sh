#!/bin/bash
#SBATCH --job-name=fsc2_M1b
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=48:00:00
#SBATCH --mem=20gb
#SBATCH --array=1-300%10
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/Model1b/logs/fsc2_M1b_%a.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/Model1b/logs/fsc2_M1b_%a.log

FSC2="/home/edmonge/wgs_acrocomia/programs/fsc28_linux64/fsc28"
MODEL_DIR="/home/edmonge/wgs_acrocomia/slurm_scripts/fastsimcoal2/Test1_Roraima/Model1b"
RUN_DIR="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/Model1b/run_${SLURM_ARRAY_TASK_ID}"

mkdir -p $RUN_DIR

# Copy input files into run directory
cp $MODEL_DIR/Model1b.tpl $RUN_DIR/
cp $MODEL_DIR/Model1b.est $RUN_DIR/
cp $MODEL_DIR/Model1b_MSFS.obs $RUN_DIR/

cd $RUN_DIR

echo "Starting Model 1b, replicate $SLURM_ARRAY_TASK_ID at $(date)"

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
  --multiSFS

echo "Finished Model1b replicate $SLURM_ARRAY_TASK_ID at $(date)"
