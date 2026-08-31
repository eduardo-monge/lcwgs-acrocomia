#!/bin/bash
#SBATCH --job-name=sfs
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=20
#SBATCH --time=168:00:00
#SBATCH --mem=100gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/02_al_pops.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/02_al_pops.log

BAMLIST="/home/edmonge/wgs_acrocomia/analyses/statistics/bamlists"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/pop_prior_SFS"
REF="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"
ANGSD="/home/edmonge/wgs_acrocomia/programs/angsd/angsd"
REALSFS="/home/edmonge/wgs_acrocomia/programs/angsd/misc/realSFS"
LOG="/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/02_al_pops.log"
SITES="/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/global.sites"

for POP in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai;
do
echo "Calling Allele Frequency for $POP in $(date)" >> "$LOG"
 $ANGSD -b $BAMLIST/${POP}.txt \
    -ref $REF \
    -anc $REF \
    -doSaf 1 \
    -GL 1 \
    -P 10 \
    -sites $SITES \
    -out $OUTDIR/${POP}_prior >> "$LOG" 2>&1

echo "Finished calling  Allele Frequency for $POP in $(date)" >> "$LOG"


echo "Calling realSFS for $POP in $(date)" >> "$LOG"

  $REALSFS $OUTDIR/${POP}_prior.saf.idx \
    -fold 1 \
    -P 10 \
    > $OUTDIR/${POP}.sfs 2>> "$LOG"

  echo "Finished realSFS for $POP in $(date)" >> "$LOG"

done
echo "FINALIZADO EM: $(date)" >> "$LOG"
