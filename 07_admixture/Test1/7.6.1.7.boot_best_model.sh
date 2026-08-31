#!/bin/bash
#SBATCH --job-name=boot_simulate
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00
#SBATCH --mem=100gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/bootstrap/logs/01_simulate.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/bootstrap/logs/01_simulate.log

set -euo pipefail

FSC2="/home/edmonge/wgs_acrocomia/programs/fsc28_linux64/fsc28"
BOOT_DIR="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/bootstrap"
SIM_DIR="$BOOT_DIR/01_simulated_sfs"

cd "$SIM_DIR"

# Copy the prepared par file
cp "$BOOT_DIR/Model1b_boot.par" .
echo "Starting bootstrap simulation at $(date)"
echo "Generating 100 pseudo-observed MSFS datasets..."

$FSC2 \
  -i Model1b_boot.par \
  -n 100 \
  -j \
  -s 0 \
  -m \
  -x \
  -I \
  --multiSFS \
  -q \
  -c 8

echo "Simulation finished at $(date)"

# Verify we got 100 subdirectories with SFS files
SFS_COUNT=$(find . -name "Model1b_boot_MSFS.obs" | wc -l)
echo "Generated $SFS_COUNT bootstrap SFS files (expected: 100)"

if [ "$SFS_COUNT" -lt 100 ]; then
    echo "[WARNING] Expected 100 but got $SFS_COUNT - check logs"
    exit 1
fi

echo "[OK] All 100 bootstrap SFS files generated"
