#!/bin/bash
#SBATCH --job-name=testchr1
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=80
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/snp_calling/geno.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/snp_calling/geno.log

BAMLIST="/home/edmonge/wgs_acrocomia/bamlist.txt"
OUTDIR="/home/edmonge/wgs_acrocomia/snp_calling"
REF="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"
ANGSD="/home/edmonge/wgs_acrocomia/angsd/angsd"
LOG="/home/edmonge/wgs_acrocomia/snp_calling/geno.log"

echo "INICIADO EM: $(date)" >> "$LOG"
$ANGSD -b $BAMLIST \
 -ref $REF \
 -out $OUTDIR/geno \
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
 -minInd 48 \
 -setMinDepth 8 \
 -setMaxDepth 350 \
 -SNP_pval 1e-6 \
 -minMaf 0.05 \
 -doGlf 2 \
 -P 8 \
>> "$LOG" 2>&1
echo "FINALIZADO EM: $(date)" >> "$LOG"
