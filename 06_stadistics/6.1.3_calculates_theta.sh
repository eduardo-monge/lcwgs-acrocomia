#!/bin/bash
#SBATCH --job-name=theta
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=40
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/theta/dotheta.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/theta/dotheta.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/theta/dotheta.log"
REALSFS="/home/edmonge/wgs_acrocomia/programs/angsd/misc/realSFS"
SAF="/home/edmonge/wgs_acrocomia/analyses/statistics/dosaf"
REAL="/home/edmonge/wgs_acrocomia/analyses/statistics/realSFS"
REF="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/theta"

for POP in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai
 do
  echo "Starting theta for: $POP in $(date)" >> "$LOG"
        $REALSFS saf2theta $SAF/${POP}.saf.idx \
        -sfs $REAL/${POP}.sfs \
        -outname $OUTDIR/${POP} \
        -anc $REF \
        -fold 1 \
        -whichFst 1 \
        -P 40 >> "$LOG" 2>&1
   echo "Finished do theta for: $POP in $(date)" >> "$LOG"
 done
echo "All populations completed in $(date)" >> "$LOG"
