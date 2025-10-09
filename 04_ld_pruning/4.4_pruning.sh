#!/bin/bash
#SBATCH --job-name=ldprunning
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=80
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/LD_prunning/prunninglist.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/LD_prunning/prunninglist.log

GRAPH="/home/edmonge/wgs_acrocomia/analyses/LD_prunning/prune_graph/target/release/prune_graph"
LD="/home/edmonge/wgs_acrocomia/analyses/LD_prunning/LDblocks.ld"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/LD_prunning"
LOG="/home/edmonge/wgs_acrocomia/analyses/LD_prunning/prunninglist.log"

eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)

echo "INICIADO EM: $(date)" >> "$LOG"
$GRAPH \
--header \
--in $LD \
--weight-field "r2_ExpG" \
--weight-filter "dist <= 20000 && r2_ExpG >= 0.2" \
--out-excl $OUTDIR/LDblocks_excluded_20000.id \
--out $OUTDIR/LDblocks_unlinked_20000.id
>> "$LOG" 2>&1
echo "FINALIZADO EM: $(date)" >> "$LOG"
