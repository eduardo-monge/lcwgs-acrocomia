OUTDIR="/home/edmonge/wgs_acrocomia/analyses/LD_prunning"
BEAGLE="/home/edmonge/wgs_acrocomia/analyses/snp_calling/geno.beagle.gz"
MAF="/home/edmonge/wgs_acrocomia/analyses/snp_calling/geno.mafs.gz"
LOG="/home/edmonge/wgs_acrocomia/analyses/LD_prunning/prunning.log"

## Prepare a geno file
zcat $BEAGLE | cut -f 4- | gzip  > $OUTDIR/for_LD_prunning.beagle.gz

## Prepare a pos file
zcat $MAF | tail -n +2 | cut -f 1,2 | gzip  > $OUTDIR/for_LD_prunning.pos.gz
