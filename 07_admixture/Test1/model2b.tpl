//Number of population samples (demes)
3
//Population effective sizes (number of genes; haploid)
NPOP_AMZ
NPOP_ROR_NOW
NPOP_SE
//Sample sizes
12
12
12
//Growth rates
0
0
0
//Number of migration matrices : 0 implies no migration between demes
0
//Historical event: time, source, sink, migrants, new size, new growth rate, migration matrix
3 historical event
TBOT 1 1 0 RESIZE_BOT 0 0
TAR_DIV 1 0 1 RESIZE_AR 0 0
T_DEEP_DIV 0 2 1 RESIZE_ANC 0 0
//Number of independent loci [chromosome]
1 0
//Per chromosome: Number of linkage blocks
1
//per Block: data type, num loci, rec. rate and mut rate + optional parameters
FREQ 1 0 2e-8 OUTEXP
