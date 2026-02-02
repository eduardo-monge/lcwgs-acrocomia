#!/bin/bash
#SBATCH --job-name=RAxML-NG
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=10
#SBATCH --time=168:00:00
#SBATCH --mem=5gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/phylo_tree/Final_tree.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/phylo_tree/Final_tree.log

LOG="/home/edmonge/wgs_acrocomia/analyses/phylo_tree/Final_tree.log"
RAXML="/home/edmonge/wgs_acrocomia/programs/RAxML-NG/raxml-ng"
MAIN="/home/edmonge/wgs_acrocomia/analyses/phylo_tree/fastME/FastME_Tree_main.nwk"
BOOT="/home/edmonge/wgs_acrocomia/analyses/phylo_tree/fastME/FastME_Tree_boot.nwk"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/phylo_tree/Final_tree"

echo "INICIADO EM: $(date)" >> "$LOG"
$RAXML --support \
 --tree $MAIN \
 --bs-trees $BOOT \
 --prefix $OUTDIR/Final_tree \
 --threads 10
echo "FINALIZADO EM: $(date)" >> "$LOG"
