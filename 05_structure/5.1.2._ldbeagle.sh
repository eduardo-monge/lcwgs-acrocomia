#!/bin/bash
#SBATCH --job-name=indexpca
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=80
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/pca/85_samples/pca.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/pca/85_samples/pca.log

LOG="/home/edmonge/wgs_acrocomia/analyses/pca/85_samples/pca.log"
ANGSD="/home/edmonge/wgs_acrocomia/angsd/angsd"
BAMLIST="/home/edmonge/wgs_acrocomia/bamlist_snpcalling_85.txt"
SNPLIST="/home/edmonge/wgs_acrocomia/analyses/pca/LDpruned_snps.list"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/pca/85_samples"
GENOMA="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"
CHROMO="/home/edmonge/wgs_acrocomia/analyses/pca/chromosome_list.txt"

echo "INICIADO EM: $(date)" >> "$LOG"
$ANGSD -b $BAMLIST \
 -ref $GENOMA \
 -out $OUTDIR/PCA_LDpruned_85 \
 -uniqueOnly 1 \
 -remove_bads 1 \
 -only_proper_pairs 1 \
 -C 50 \
 -baq 1 \
 -minMapQ 20 \
 -minQ 20 \
 -P 10 \
 -doMajorMinor 3 \
 -doCounts 1 \
 -GL 1 \
 -doGlf 2 \
 -sites $SNPLIST \
 -rf $CHROMO
echo "FINALIZADO EM: $(date)" >> "$LOG"
