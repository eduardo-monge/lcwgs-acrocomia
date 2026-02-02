#!/bin/bash
#SBATCH --job-name=ldprunning
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=16
#SBATCH --time=168:00:00
#SBATCH --mem=200gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/LD_Decay/LD_Pops.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/LD_Decay/LD_Pops.log

export LD_LIBRARY_PATH=$HOME/miniconda3/lib:$LD_LIBRARY_PATH
export PATH=$HOME/wgs_acrocomia/ngsLD:$PATH


NGSLD="/home/edmonge/wgs_acrocomia/programs/ngsLD/ngsLD"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/LD_Decay/LD_Pops"
BEAGLE="/home/edmonge/wgs_acrocomia/analyses/LD_Decay/eddited_to_analyses"
POS="/home/edmonge/wgs_acrocomia/analyses/LD_Decay/eddited_to_analyses"
LOG="/home/edmonge/wgs_acrocomia/analyses/LD_Decay/LD_Pops.log"

declare -A NIND
declare -A NSITES

NIND["Amazonas"]=9
NSITES["Amazonas"]=3419709

NIND["Costarican"]=17
NSITES["Costarican"]=910641

NIND["Intumescens"]=8
NSITES["Intumescens"]=843871

NIND["Mesoamerica"]=18
NSITES["Mesoamerica"]=640022

NIND["Mineiro"]=9
NSITES["Mineiro"]=2330509

NIND["Roraima"]=6
NSITES["Roraima"]=832511

NIND["Sudeste"]=11
NSITES["Sudeste"]=3907181

NIND["Totai"]=7
NSITES["Totai"]=3765862

for POP in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai;
do
echo "Starting in: $(date)" >> "$LOG"
echo "Doing LD for $POP in $(date)" >> "$LOG"

$NGSLD \
--geno $BEAGLE/for_analysis_${POP}.beagle.gz \
--pos $POS/for_analysis_${POP}.pos.gz \
--probs \
--n_ind ${NIND[$POP]} \
--n_sites ${NSITES[$POP]} \
--max_kb_dist 500 \
--n_threads 16 \
--out $OUTDIR/${POP}.ld >> "$LOG" 2>&1

echo "Finished LD for $POP in $(date)" >> "$LOG"
done
echo "FINALIZADO EM: $(date)" >> "$LOG"
