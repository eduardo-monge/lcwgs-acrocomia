#!/bin/bash
#SBATCH --job-name=FastME
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=80
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/phylo_tree/FastME.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/phylo_tree/FastME.log

LOG="/home/edmonge/wgs_acrocomia/analyses/phylo_tree/FastME.log"
FASTME="/home/edmonge/wgs_acrocomia/programs/FastME/src/fastme"
MATRIX="/home/edmonge/wgs_acrocomia/analyses/phylo_tree/ngsDist/Distance_tree.dist"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/phylo_tree/fastME"

echo "INICIADO EM: $(date)" >> "$LOG"
$FASTME \
-T 80 \
-i $MATRIX \
-D 1001 \
-m BioNJ \
-q \
-s \
-o $OUTDIR/FastME_Tree.nwk
echo "FINALIZADO EM: $(date)" >> "$LOG"
