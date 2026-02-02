#!/bin/bash
#SBATCH --job-name=realSFS
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=100
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/realSFS/realSFS.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/realSFS/realSFS.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/realSFS/realSFS.log"
REALSFS="/home/edmonge/wgs_acrocomia/angsd/misc/realSFS"
SAF="/home/edmonge/wgs_acrocomia/analyses/statistics/dosaf"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/realSFS"

for POP in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai
 do
  echo "Starting Real SFS for: $POP in $(date)" >> "$LOG"
$REALSFS $SAF/${POP}.saf.idx \
 -P 10 \
 -fold 1 \
 >$OUTDIR/${POP}.sfs
   echo "Finished do Real SFS for: $POP in $(date)" >> "$LOG"
 done
echo "All populations completed in $(date)" >> "$LOG"
