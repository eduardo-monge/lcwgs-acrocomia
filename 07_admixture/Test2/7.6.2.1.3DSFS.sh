#!/bin/bash
#SBATCH --job-name=4DSFS
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=20
#SBATCH --time=168:00:00
#SBATCH --mem=500gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test2_Intumescens/01_4D-SFS.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test2_Intumescens/01_4D-SFS.log

LOG="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test2_Intumescens/01_4D-SFS.log"
REALSFS="/home/edmonge/wgs_acrocomia/programs/angsd/misc/realSFS"
SAF="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/1D-SFS"
OUT="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test2_Intumescens"

echo "Starting at $(date)" >> "$LOG"

$REALSFS \
  $SAF/Mineiro_neutral.saf.idx \
  $SAF/Amazonas_neutral.saf.idx \
  $SAF/Roraima_neutral.saf.idx \
  $SAF/Intumescens_neutral.saf.idx \
  -fold 1 \
  -P 20 \
  -maxiter 100 \
  > $OUT/Test2_Intu.SFS 2>> "$LOG"

echo "Pairwise 4D-SFS comparisons completed at $(date)" >> "$LOG"
echo "Output file size: $(ls -lh $OUT/Test2_Intu.SFS | awk '{print $5}')" >> "$LOG"
echo "Number of values: $(wc -w < $OUT/Test2_Intu.SFS)" >> "$LOG"
