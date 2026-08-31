#!/bin/bash
#SBATCH --job-name=final_all
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=20
#SBATCH --time=168:00:00
#SBATCH --mem=100gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/03_al_pops.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/03_al_pops.log

BAMLIST="/home/edmonge/wgs_acrocomia/analyses/statistics/bamlists"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/final_af_per_pop"
REF="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"
ANGSD="/home/edmonge/wgs_acrocomia/programs/angsd/angsd"
LOG="/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/03_al_pops.log"
SITES="/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/global.sites"
PRIOR="/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/pop_prior_SFS"

for POP in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai;
do
echo "Calling Allele Frequency for $POP in $(date)" >> "$LOG"
 $ANGSD -b $BAMLIST/${POP}.txt \
    -ref $REF \
    -anc $REF \
    -doMaf 1 \
    -doMajorMinor 3 \
    -GL 1 \
    -pest $PRIOR/${POP}.sfs \
    -sites $SITES \
    -P 10 \
    -out $OUTDIR/${POP}_freqs >> "$LOG" 2>&1

echo "Finished calling  Allele Frequency for $POP in $(date)" >> "$LOG"
done

echo "FINALIZADO EM: $(date)" >> "$LOG"
