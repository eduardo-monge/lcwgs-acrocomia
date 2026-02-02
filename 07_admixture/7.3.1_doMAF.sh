(base) edmonge@dayhoff1:~/wgs_acrocomia/slurm_scripts/TreeMix$ cat 01_GLCalling_LD
#!/bin/bash
#SBATCH --job-name=domaf
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=10
#SBATCH --time=168:00:00
#SBATCH --mem=100gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/TreeMix/01_domaf.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/TreeMix/01_domaf.log

BAMLIST="/home/edmonge/wgs_acrocomia/analyses/statistics/bamlists"
OUTDIR="/home/edmonge/wgs_acrocomia/analyses/TreeMix/Maf"
REF="/home/edmonge/wgs_acrocomia/genome/macauba.chrs.fa"
ANGSD="/home/edmonge/wgs_acrocomia/programs/angsd/angsd"
LOG="/home/edmonge/wgs_acrocomia/analyses/TreeMix/01_domaf.log"
SNPLIST="/home/edmonge/wgs_acrocomia/analyses/pca/LDpruned_snps.list"

for POP in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai;
do
echo "Calling Maf for $POP in $(date)" >> "$LOG"
$ANGSD -b $BAMLIST/${POP}.txt \
 -ref $REF \
 -anc $REF \
 -out $OUTDIR/${POP} \
 -sites $SNPLIST \
 -uniqueOnly 1 \
 -remove_bads 1 \
 -only_proper_pairs 1 \
 -C 50 \
 -baq 1 \
 -minMapQ 20 \
 -minQ 20 \
 -GL 1 \
 -doMajorMinor 5 \
 -doMaf 1 \
 -P 10 >> "$LOG" 2>&1
echo "Finished calling GL for $POP in $(date)" >> "$LOG"
done
echo "FINALIZADO EM: $(date)" >> "$LOG"
