#!/bin/bash
#SBATCH --job-name=PCAngsd
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=80
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/Ohana/convert.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/Ohana/convert.log

LOG="/home/edmonge/wgs_acrocomia/analyses/Ohana/convert.log"
OHANA="/home/edmonge/wgs_acrocomia/ohana/bin/convert"
BEAGLE="/home/edmonge/wgs_acrocomia/analyses/Ohana/PCA_LDpruned_85.beagle"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/Ohana"

echo "INICIADO EM: $(date)" >> "$LOG"
$OHANA bgl2lgm $BEAGLE $OUTDIR/Ohana.lgm
echo "FINALIZADO EM: $(date)" >> "$LOG"
