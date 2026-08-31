OUTDIR="/home/edmonge/wgs_acrocomia/analyses/LD_Decay/eddited_to_analyses"
BEAGLE="/home/edmonge/wgs_acrocomia/analyses/LD_Decay"
MAF="/home/edmonge/wgs_acrocomia/analyses/LD_Decay"
LOG="/home/edmonge/wgs_acrocomia/analyses/LD_Decay/convert.log"

for POP in Mesoamerica Costarican Roraima Amazonas Sudeste Mineiro Intumescens Totai;
do
echo "Converting $POP in $(date)" >> "$LOG"
## Prepare a geno file
zcat $BEAGLE/${POP}.beagle.gz | cut -f 4- | gzip  > $OUTDIR/for_analysis_${POP}.beagle.gz

## Prepare a pos file
zcat $MAF/${POP}.mafs.gz | tail -n +2 | cut -f 1,2 | gzip  > $OUTDIR/for_analysis_${POP}.pos.gz

echo "Done $POP in $(date)" >> "$LOG"
done
echo "Done in $(date)" >> "$LOG"
