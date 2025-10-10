#!/bin/bash
#SBATCH --job-name=indexpca
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=80
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/pca/pca.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/pca/pca.log

LOG="/home/edmonge/wgs_acrocomia/analyses/pca/pca.log"
ANGSD="/home/edmonge/wgs_acrocomia/angsd/angsd"
BAMLIST="/home/edmonge/wgs_acrocomia/bamlist.txt"
SNPLIST="/home/edmonge/wgs_acrocomia/analyses/pca/20000/LDpruned_20000.list"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/pca"
GENOMA="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"

echo "INICIADO EM: $(date)" >> "$LOG"
samtools faidx $GENOMA
$ANGSD sites index $SNPLIST
echo "FINALIZADO EM: $(date)" >> "$LOG"
