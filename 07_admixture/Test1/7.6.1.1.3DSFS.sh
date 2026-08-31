#!/bin/bash
#SBATCH --job-name=3DSFS
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=20
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/01_3D-SFS.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/01_3D-SFS.log

LOG="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/01_3D-SFS.log"
REALSFS="/home/edmonge/wgs_acrocomia/programs/angsd/misc/realSFS"
SAF="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/1D-SFS"
OUT="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima"

echo "Starting at $(date)" >> "$LOG"

$REALSFS \
  $SAF/Amazonas_neutral.saf.idx \
  $SAF/Roraima_neutral.saf.idx \
  $SAF/Sudeste_neutral.saf.idx \
  -fold 1 \
  -P 20 \
  -maxiter 100 \
  > $OUT/Amazonas_Roraima_Sudeste.3dSFS 2>> "$LOG"

echo "Pairwise 3D-SFS comparisons completed at $(date)" >> "$LOG"
echo "Output file size: $(ls -lh $OUT/Amazonas_Roraima_Sudeste.3dSFS | awk '{print $5}')" >> "$LOG"
echo "Number of values: $(wc -w < $OUT/Amazonas_Roraima_Sudeste.3dSFS)" >> "$LOG"
