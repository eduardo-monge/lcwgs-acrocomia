#!/bin/bash
#SBATCH --job-name=ngsDist
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=100
#SBATCH --time=168:00:00
#SBATCH --mem=200gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/phylo_tree/dist.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/phylo_tree/dist.log

LOG="/home/edmonge/wgs_acrocomia/analyses/phylo_tree/dist.log"
NGSDIST="/home/edmonge/wgs_acrocomia/programs/ngsDist/ngsDist"
BEAGLE="/home/edmonge/wgs_acrocomia/analyses/phylo_tree/LDpruned_85.beagle.gz"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/phylo_tree/ngsDist"
LABELS="/home/edmonge/wgs_acrocomia/analyses/phylo_tree/samples.txt"

echo "INICIADO EM: $(date)" >> "$LOG"
$NGSDIST --geno $BEAGLE \
--n_ind 85 \
--n_sites 1060594 \
--probs true \
--n_boot_rep 1000 \
--labels $LABELS \
--out $OUTDIR/Distance_tree.dist \
--n_threads 100
echo "FINALIZADO EM: $(date)" >> "$LOG"
