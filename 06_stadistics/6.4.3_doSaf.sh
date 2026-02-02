#!/bin/bash
#SBATCH --job-name=indexFst
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=80
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/indexFst/indexFst.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/indexFst/indexFst.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/indexFst/indexFst.log"
REALSFS="/home/edmonge/wgs_acrocomia/programs/angsd/misc/realSFS"
SAF="/home/edmonge/wgs_acrocomia/analyses/statistics/dosaf"
PAIRSFS="/home/edmonge/wgs_acrocomia/analyses/statistics/2D-SFS"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/statistics/indexFst"

POPS=(Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai)

# Step 1: FST index
for ((i=0; i<${#POPS[@]}; i++)); do
  for ((j=i+1; j<${#POPS[@]}; j++)); do
    POP1=${POPS[i]}
    POP2=${POPS[j]}
    echo "Starting FST index for: ${POP1} vs ${POP2} at $(date)" >> "$LOG"

    $REALSFS fst index $SAF/${POP1}.saf.idx $SAF/${POP2}.saf.idx \
      -sfs $PAIRSFS/${POP1}_${POP2}.sfs \
      -fstout $OUTDIR/${POP1}_${POP2} \
      -whichFst 1 -P 80

    echo "Finished FST index for: ${POP1} vs ${POP2} at $(date)" >> "$LOG"
  done
done

echo "All index computations completed at $(date)" >> "$LOG"

#Step 2:FST
for ((i=0; i<${#POPS[@]}; i++)); do
  for ((j=i+1; j<${#POPS[@]}; j++)); do
    POP1=${POPS[i]}
    POP2=${POPS[j]}
    echo "Starting stats for: ${POP1} vs ${POP2} at $(date)" >> "$LOG"

    $REALSFS fst stats $OUTDIR/${POP1}_${POP2}.fst.idx -P 80 > $OUTDIR/${POP1}_${POP2}.globalFst.txt

    echo "Finished stats for: ${POP1} vs ${POP2} at $(date)" >> "$LOG"
  done
done
echo "All stats comparisons completed at $(date)" >> "$LOG"

#Step 3:FST table
for ((i=0; i<${#POPS[@]}; i++)); do
  for ((j=i+1; j<${#POPS[@]}; j++)); do
    POP1=${POPS[i]}
    POP2=${POPS[j]}
    echo "Starting print for: ${POP1} vs ${POP2} at $(date)" >> "$LOG"

    $REALSFS fst print $OUTDIR/${POP1}_${POP2}.fst.idx -P 80 > $OUTDIR/${POP1}_${POP2}_FST.txt

    echo "Finished print for: ${POP1} vs ${POP2} at $(date)" >> "$LOG"
  done
done
echo "All stats comparisons completed at $(date)" >> "$LOG"
