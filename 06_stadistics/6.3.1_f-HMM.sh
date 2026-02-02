#!/bin/bash
#SBATCH --job-name=ngsF-HMM
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=30
#SBATCH --time=200:00:00
#SBATCH --mem=200gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/F-HMM/ngsFHMM.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/F-HMM/ngsFHMM.log


NGSFHMM="/home/edmonge/wgs_acrocomia/programs/ngsF-HMM/ngsF-HMM.sh"
RSCRIP="/home/edmonge/wgs_acrocomia/programs/ngsF-HMM/scripts/ngsF-HMMplot.R"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/F-HMM"
BEAGLE="/home/edmonge/wgs_acrocomia/analyses/LD_Decay/eddited_to_analyses"
LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/F-HMM/ngsFHMM.log"

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

for POP in Sudeste Mineiro Intumescens Totai;
do
echo "Starting in: $(date)" >> "$LOG"

echo "Doing F for $POP in $(date)" >> "$LOG"
$NGSFHMM \
--geno $BEAGLE/for_analysis_${POP}.beagle.gz \
--pos $BEAGLE/for_analysis_${POP}.pos.gz \
--lkl \
--n_ind ${NIND[$POP]} \
--n_sites ${NSITES[$POP]} \
--n_threads 30 \
--min_epsilon 1e-6 \
--out $OUTDIR/${POP} >> "$LOG" 2>&1

echo "Finished F for $POP in $(date)" >> "$LOG"

echo "Doing IBD graph for $POP in $(date)" >> "$LOG"
Rscript $RSCRIP \
--infile $OUTDIR/${POP}.ibd \
--outfile $OUTDIR/${POP}.pdf

echo "Finished IBD graph for $POP in $(date)" >> "$LOG"

done
echo "FINALIZADO EM: $(date)" >> "$LOG"
