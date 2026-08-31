#!/bin/bash
#SBATCH --job-name=Convert_PCA
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=20
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/outliers/PCAngsd/02_convert.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/outliers/PCAngsd/02_convert.log

LOG="/home/edmonge/wgs_acrocomia/analyses/outliers/PCAngsd/02_convert.log"
PCANGSD="/home/edmonge/wgs_acrocomia/programs/pcangsd/scripts/pcadapt.R"
ZSCORE="/home/edmonge/wgs_acrocomia/analyses/outliers/PCAngsd/PCAngsd.pcadapt.zscores"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/outliers/PCAngsd"

echo "INICIADO EM: $(date)" >> "$LOG"
Rscript $PCANGSD $ZSCORE
echo "FINALIZADO EM: $(date)" >> "$LOG"
