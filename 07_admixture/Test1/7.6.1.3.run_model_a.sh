#!/bin/bash
#SBATCH --job-name=fsc2_M1a
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=8
#SBATCH --time=48:00:00
#SBATCH --mem=20gb
#SBATCH --array=1-300%10
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/Model1a/logs/fsc2_M1a_%a.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/Model1a/logs/fsc2_M1a_%a.log

FSC2="/home/edmonge/wgs_acrocomia/programs/fsc28_linux64/fsc28"
MODEL_DIR="/home/edmonge/wgs_acrocomia/slurm_scripts/fastsimcoal2/Test1_Roraima/Model1a"
RUN_DIR="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/Model1a/run_${SLURM_ARRAY_TASK_ID}"

mkdir -p $RUN_DIR

# Copy input files into run directory
cp $MODEL_DIR/Model1a.tpl $RUN_DIR/
cp $MODEL_DIR/Model1a.est $RUN_DIR/
cp $MODEL_DIR/Model1a_MSFS.obs $RUN_DIR/

cd $RUN_DIR

echo "Starting Model 1a, replicate $SLURM_ARRAY_TASK_ID at $(date)"

$FSC2 \
  -t Model1a.tpl \
  -e Model1a.est \
  -n 500000 \
  -m \
  -M \
  -L 60 \
  -q \
  -c 8 \
  -B 0 \
  --multiSFS

echo "Finished replicate $SLURM_ARRAY_TASK_ID at $(date)"
