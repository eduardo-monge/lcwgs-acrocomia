#!/bin/bash
#SBATCH --job-name=treemix1
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --time=168:00:00
#SBATCH --mem=100gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/TreeMix/03_firstree_bootstrap.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/TreeMix/03_firstree_bootstrap.log

LOG="/home/edmonge/wgs_acrocomia/analyses/TreeMix/03_firstree_bootstrap.log"
TREEMIX="/home/edmonge/wgs_acrocomia/programs/Treemix/src/treemix"
TREEDIR="/home/edmonge/wgs_acrocomia/analyses/TreeMix"


for m in {0..10}; do
 for i in {1..10}; do
 SEED=$RANDOM
 echo "START: m=$m i=$i at $(date)" >> "$LOG"
  $TREEMIX \
  -i "$TREEDIR/Acrocomia.treemix.in.gz" \
  -o "$TREEDIR/out_m_bootstrap/treemix.${i}.${m}" \
  -global \
  -seed $SEED \
  -m ${m} \
  -k 500 \
  -bootstrap \
  -se \
  -noss
  echo "DONE: m=$m i=$i at $(date)" >> "$LOG"
 done
done
echo "Done all m at $(date)" >> "$LOG"
