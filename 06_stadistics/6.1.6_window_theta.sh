#!/bin/bash
#SBATCH --job-name=theta_window
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=40
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/theta/windowtheta.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/theta/windowtheta.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/theta/windowtheta.log"
THETASTAT="/home/edmonge/wgs_acrocomia/programs/angsd/misc/thetaStat"
THETA="/home/edmonge/wgs_acrocomia/analyses/statistics/theta"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/theta"

for POP in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai

 do
  echo "Starting theta 15kb  for: $POP in $(date)" >> "$LOG"
        #Calculate fixed window theta
        $THETASTAT do_stat \
        $THETA/${POP}.thetas.idx \
        -win 15000 \
        -step 15000 \
        -outnames $OUTDIR/${POP}_window15kb

   echo "Finished theta 15kb for: $POP in $(date)" >> "$LOG"


  echo "Starting theta per chromosome for: $POP in $(date)" >> "$LOG"
        #Calculate per-chromosome average theta
        $THETASTAT do_stat \
        $THETA/${POP}.thetas.idx \
        -outnames $OUTDIR/${POP}_average_thetas

   echo "Finished theta per chromosome for: $POP in $(date)" >> "$LOG"
 done

echo "All populations completed in $(date)" >> "$LOG"
