#!/bin/bash
#SBATCH --job-name=2DSFS
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=100
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/2D-SFS/2D-SFS.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/2D-SFS/2D-SFS.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/2D-SFS/2D-SFS.log"
REALSFS="/home/edmonge/wgs_acrocomia/programs/angsd/misc/realSFS"
SAF="/home/edmonge/wgs_acrocomia/analyses/statistics/dosaf"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/2D-SFS"

POPS=(Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai)

for ((i=0; i<${#POPS[@]}; i++)); do
  for ((j=i+1; j<${#POPS[@]}; j++)); do
    POP1=${POPS[i]}
    POP2=${POPS[j]}
    echo "Starting 2D-SFS for: ${POP1} vs ${POP2} at $(date)" >> "$LOG"

    $REALSFS $SAF/${POP1}.saf.idx $SAF/${POP2}.saf.idx -P 100 > $OUTDIR/${POP1}_${POP2}.sfs

    echo "Finished 2D-SFS for: ${POP1} vs ${POP2} at $(date)" >> "$LOG"
  done
done

echo "All pairwise 2D-SFS comparisons completed at $(date)" >> "$LOG"
