#!/bin/bash
#SBATCH --job-name=treemix
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=168:00:00
#SBATCH --mem=100gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/TreeMix/04_final_tree.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/TreeMix/04_final_tree.log

LOG="/home/edmonge/wgs_acrocomia/analyses/TreeMix/04_final_tree.log"
TREEMIX="/home/edmonge/wgs_acrocomia/programs/Treemix/src/treemix"
TREEDIR="/home/edmonge/wgs_acrocomia/analyses/TreeMix"

for m in 3 4; do
CURRENT_OUTDIR="$TREEDIR/final_tree/m${m}"
 mkdir -p "$CURRENT_OUTDIR"

for b in {1..1000}; do
 SEED=$RANDOM
 echo "START: m=$m b=$b at $(date)" >> "$LOG"
  $TREEMIX \
  -i "$TREEDIR/Acrocomia.treemix.in.gz" \
  -o "$CURRENT_OUTDIR/treemix_m${m}_boot${b}" \
  -global \
  -seed $SEED \
  -m ${m} \
  -k 500 \
  -bootstrap \
  -root Totai \
  -se \
  -noss
  echo "DONE: m=$m b=$b at $(date)" >> "$LOG"
 done
done
echo "Done all m at $(date)" >> "$LOG"
