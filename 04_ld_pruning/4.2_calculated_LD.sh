#!/bin/bash
#SBATCH --job-name=ldprunning
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=80
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/LD_prunning/prunning.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/LD_prunning/prunning.log

export LD_LIBRARY_PATH=$HOME/miniconda3/lib:$LD_LIBRARY_PATH
export PATH=$HOME/wgs_acrocomia/ngsLD:$PATH

NGSLD="/home/edmonge/wgs_acrocomia/ngsLD/ngsLD"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/LD_prunning"
BEAGLE="/home/edmonge/wgs_acrocomia/analyses/LD_prunning/for_LD_prunning.beagle.gz"
POS="/home/edmonge/wgs_acrocomia/analyses/LD_prunning/for_LD_prunning.pos.gz"
LOG="/home/edmonge/wgs_acrocomia/analyses/LD_prunning/prunning.log"

echo "INICIADO EM: $(date)" >> "$LOG"
$NGSLD \
--geno $BEAGLE \
--pos $POS \
--probs \
--n_ind 96 \
--n_sites 2929140 \
--max_kb_dist 100 \
--n_threads 16 \
--out $OUTDIR/LDblocks.ld
>> "$LOG" 2>&1
echo "FINALIZADO EM: $(date)" >> "$LOG"
