#!/bin/bash
#SBATCH --job-name=indexpca
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=100
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/dosaf/dosaf.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/dosaf/dosaf.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/dosaf/dosaf.log"
ANGSD="/home/edmonge/wgs_acrocomia/angsd/angsd"
BAMLIST="/home/edmonge/wgs_acrocomia/analyses/statistics/bamlists"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/dosaf"
GENOMA="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"


for POP in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai
 do
  echo "Starting doSaf for: $POP population in $(date)" >> "$LOG"
$ANGSD -b $BAMLIST/${POP}.txt \
 -ref $GENOMA \
 -anc $GENOMA \
 -out $OUTDIR/$POP \
 -uniqueOnly 1 \
 -remove_bads 1 \
 -only_proper_pairs 1 \
 -C 50 \
 -baq 1 \
 -minMapQ 20 \
 -minQ 20 \
 -setMinDepth 8 \
 -setMaxDepth 350 \
 -P 10 \
 -doCounts 1 \
 -GL 1 \
 -doSaf 1
   echo "Finished doSaf for: $POP in $(date)" >> "$LOG"
 done
echo "All populations completed in $(date)" >> "$LOG"
