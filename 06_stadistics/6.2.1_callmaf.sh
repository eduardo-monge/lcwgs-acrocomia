#!/bin/bash
#SBATCH --job-name=domaf
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=10
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/het/domaf.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/het/domaf.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/het/domaf.log"
MAF="/home/edmonge/wgs_acrocomia/analyses/statistics/het"
ANGSD="/home/edmonge/wgs_acrocomia/programs/angsd/angsd"
BAMLIST="/home/edmonge/wgs_acrocomia/bamlist_snpcalling_85.txt"
REF="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"


        #1 - Generated the maf file
        echo "Doing maf file in  $(date)" >> "$LOG"
        $ANGSD -b $BAMLIST \
        -ref $REF \
        -out $MAF/globalmaf \
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
        -setMinDepth 8 \
        -setMaxDepth 350 \
        -SNP_pval 1e-6 \
        -minMaf 0.05 \
        -doGlf 2 \
        -P 10 \
        >> "$LOG" 2>&1
        echo "FINALIZADO EM: $(date)" >> "$LOG"
