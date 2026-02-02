#!/bin/bash
#SBATCH --job-name=theta
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=40
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/theta/printheta.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/theta/printheta.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/theta/printheta.log"
THETASTAT="/home/edmonge/wgs_acrocomia/programs/angsd/misc/thetaStat"
THETA="/home/edmonge/wgs_acrocomia/analyses/statistics/theta"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/theta"

for POP in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai
 do
  echo "Starting theta print for: $POP in $(date)" >> "$LOG"
        $THETASTAT print \
        $THETA/${POP}.thetas.idx > $OUTDIR/${POP}.PopGenEstimates.Print
done
   echo "Finished theta print for: $POP in $(date)" >> "$LOG"
 done
echo "All populations completed in $(date)" >> "$LOG"
