
# Genotype Likelihoods (SNP Calling)
Analysis to create the list of BAM files with full paths and to calculate genotype likelihoods using the ANGSD program with the SAMtools model. The script also performs sequence quality filtering and generates the output file in Beagle likelihood format (.beagle.gz) for subsequent analyses. The minimum and maximum depth values were calculated based on the depth quantiles.

   * [3.1. Created BAM list](3.1_bamlist)
   * [3.2. Calculated Genotype Likelihood (GL)](3.1_genolike.sh) - Using SAMtools model in ANGSD
