#!/bin/bash
#SBATCH --job-name=PCAngsd
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=80
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/pca/85_samples/PCAngsd.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/pca/85_samples/PCAngsd.log

LOG="/home/edmonge/wgs_acrocomia/analyses/pca/85_samples/PCAngsd.log"
PCANGSD="/home/edmonge/wgs_acrocomia/pcangsd/pcangsd"
BEAGLE="/home/edmonge/wgs_acrocomia/analyses/pca/85_samples/PCA_LDpruned_85.beagle.gz"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/pca/85_samples"

echo "INICIADO EM: $(date)" >> "$LOG"
pcangsd \
--beagle $BEAGLE \
--out $OUTDIR/PCA_matrix_85
echo "FINALIZADO EM: $(date)" >> "$LOG"
