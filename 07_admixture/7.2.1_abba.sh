#!/bin/bash
#SBATCH --job-name=abba
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=168:00:00
#SBATCH --mem=200gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/Abbababa/abba.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/Abbababa/abba.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/Abbababa/abba.log"
ABADIR="/home/edmonge/wgs_acrocomia/analyses/statistics/Abbababa"
ANGSD="/home/edmonge/wgs_acrocomia/programs/angsd/angsd"


echo "INICIADO EM: $(date)" >> "$LOG"
$ANGSD -doAbbababa2 1 \
-bam $ABADIR/bam.filelist \
-sizeFile $ABADIR/sizeFile.size \
-doCounts 1 \
-out $ABADIR/results \
-useLast 1 \
-blockSize 5000000 \
-minQ 20 \
-minMapQ 30 \
-p 10 \
-remove_bads 1 \
-uniqueOnly 1 \
-only_proper_pairs 1 \
-rmTrans 0
echo "FINALIZADO EM: $(date)" >> "$LOG"
