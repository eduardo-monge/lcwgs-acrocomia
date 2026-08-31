#!/bin/bash
#SBATCH --job-name=dosaf
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=10
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/01_saf_step.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/01_saf_step.log

LOG="/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/01_saf_step.log"
OUT="/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest"
ANGSD="/home/edmonge/wgs_acrocomia/programs/angsd/angsd"
BAMLIST="/home/edmonge/wgs_acrocomia/bamlist_snpcalling_85.txt"
REF="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"
REALSFS="/home/edmonge/wgs_acrocomia/programs/angsd/misc/realSFS"

#1. global SAF + MAF
echo "Doing saf file in $(date)" >> "$LOG"
$ANGSD -b $BAMLIST \
  -ref $REF \
  -anc $REF \
  -out $OUT/globalMAF \
  -uniqueOnly 1 \
  -remove_bads 1 \
  -only_proper_pairs 1 \
  -C 50 \
  -minMaf 0.05 \
  -baq 1 \
  -minMapQ 20 \
  -minQ 20 \
  -setMinDepth 8 \
  -setMaxDepth 350 \
  -P 10 \
  -doCounts 1 \
  -GL 1 \
  -doMaf 1 \
  -doMajorMinor 1 \
  -SNP_pval 1e-6 >> "$LOG" 2>&1

echo "Finished SAF: $(date)" >> "$LOG"

#2. Extract and index site list
echo "Doing sites index in $(date)" >> "$LOG"
zcat $OUT/globalMAF.mafs.gz | tail -n +2 \
  | awk '{print $1"\t"$2"\t"$3"\t"$4}' > $OUT/global.sites

$ANGSD sites index $OUT/global.sites >> "$LOG" 2>&1
echo "Finished index: $(date)" >> "$LOG"
