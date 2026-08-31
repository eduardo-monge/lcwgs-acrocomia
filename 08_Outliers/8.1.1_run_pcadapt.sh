#!/bin/bash
#SBATCH --job-name=PCAdapt
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=20
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/outliers/PCAngsd/PCAngsd.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/outliers/PCAngsd/PCAngsd.log

LOG="/home/edmonge/wgs_acrocomia/analyses/outliers/PCAngsd/PCAngsd.log"
BEAGLE="/home/edmonge/wgs_acrocomia/analyses/outliers/PCAngsd/full_85_samples.beagle.gz"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/outliers/PCAngsd"

echo "INICIADO EM: $(date)" >> "$LOG"
pcangsd \
--beagle $BEAGLE \
--pcadapt \
--threads 20 \
-e 5 \
--sites-save \
--out $OUTDIR
echo "FINALIZADO EM: $(date)" >> "$LOG"
