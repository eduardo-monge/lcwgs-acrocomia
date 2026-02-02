#!/bin/bash
#SBATCH --job-name=theta
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=40
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/theta/global_test/printglobal.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/theta/global_test/printglobal.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/theta/global_test/printglobal.log"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/theta/global_test"
BAMLIST="/home/edmonge/wgs_acrocomia/analyses/statistics/bamlists"
THETA="/home/edmonge/wgs_acrocomia/analyses/statistics/theta"

FINAL="$OUTDIR/global_theta_allpops.txt"

for query in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai
do
  N_IND=$(wc -l < $BAMLIST/${query}.txt)
  Rscript --vanilla \
      $OUTDIR/global.R \
      $THETA/${query}.PopGenEstimates.Print \
      $N_IND \
      $query \
      >> $FINAL
done
