#!/bin/bash
#SBATCH --job-name=R_abba
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=168:00:00
#SBATCH --mem=200gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/Abbababa/R_abba.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/Abbababa/R_abba.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/Abbababa/R_abba.log"
ABADIR="/home/edmonge/wgs_acrocomia/analyses/statistics/Abbababa"
ANGSDR="/home/edmonge/wgs_acrocomia/programs/angsd/R/estAvgError.R"
OUT="/home/edmonge/wgs_acrocomia/analyses/statistics/Abbababa/FinalResults"

echo "INICIADO EM: $(date)" >> "$LOG"
Rscript $ANGSDR  \
angsdFile=$ABADIR/results \
sizeFile=$ABADIR/sizeFile.size \
out=$OUT/FinalStats \
nameFile=$ABADIR/pops.txt
echo "FINALIZADO EM: $(date)" >> "$LOG"
