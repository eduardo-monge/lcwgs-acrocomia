#!/bin/bash
#SBATCH --job-name=testchr1
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=80
#SBATCH --time=168:00:00
#SBATCH --mem=100gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/LD_Decay/geno_pops.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/LD_Decay/geno_pops.log

BAMLIST="/home/edmonge/wgs_acrocomia/analyses/statistics/bamlists"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/LD_Decay"
REF="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"
ANGSD="/home/edmonge/wgs_acrocomia/programs/angsd/angsd"
LOG="/home/edmonge/wgs_acrocomia/analyses/LD_Decay/geno_pops.log"

for POP in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai;
do
echo "Calling GL for $POP in $(date)" >> "$LOG"
$ANGSD -b $BAMLIST/${POP}.txt \
 -ref $REF \
 -out $OUTDIR/${POP} \
 -uniqueOnly 1 \
 -remove_bads 1 \
 -only_proper_pairs 1 \
 -C 50 \
 -baq 1 \
 -minMapQ 20 \
 -minQ 20 \
 -GL 1 \
 -doCounts 1 \
 -doDepth 1 \
 -dumpCounts 1 \
 -doMajorMinor 1 \
 -doMaf 1 \
 -SNP_pval 1e-6 \
 -minMaf 0.05 \
 -doGlf 2 \
 -P 10 >> "$LOG" 2>&1
echo "Finished calling GL for $POP in $(date)" >> "$LOG"
done
echo "FINALIZADO EM: $(date)" >> "$LOG"
