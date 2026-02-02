# Genomic statistics
Here are the scripts for calculating population statistics (Nucleotide diversity (π), Watterson’s θ (θw), and Tajima’s D.) with ANGSD, as well as Ho and FIS from the data. Also included are global and windowed FST statistics. 

   * [6.1. Nucleotide diversity (π), Watterson’s θ (θw), and Tajima’s D](06_stadistics/)
       *  [6.1.1. Calculate SAF per population](06_stadistics/6.1.1_doSaf.sh) - With ANGSD
       *  [6.1.2. Calculate reaal SFS](06_stadistics/6.1.2._realSFS.sh) - With ANGSD
       *  [6.1.3. Calculated stadistics per population](06_stadistics/6.1.3_calculates_theta.sh) - With ANGSD
       *  [6.1.4. Print stadistics per population](06_stadistics/6.1.4_print_theta.sh) - With ANGSD
       *  [6.1.5. Calculated global stadistics per population](06_stadistics/6.1.5_global_theta.sh) wiht R
            - [R scritp to calculated global stats per population](06_stadistics/6.1.5.1_Rscript_global_theta.sh) - Script provided by [Dr. Homère J. Alves Monteiro](https://github.com/HomereAMK/EUostrea/blob/b32a00efeb9244ec63e91e088f01827e604119c3/Markdowns/05_PopGenEstimates.md).
       *  [6.1.6. Calculated stadistics in 15kb windows](06_stadistics/6.1.6_window_theta.sh) - With ANGSD
   * [6.2. Heterozygous sites (Ho)](06_stadistics/)
     * [6.2.1. Calculated MAF file per population](06_stadistics/6.2.1_callmaf.sh) - With ANGSD
     * [6.2.2. Create pos file based on the MAF file](06_stadistics/6.2.2_create_pos.sh) - Bash script
     * [6.2.3. Call SAF based on position file (pos file)](06_stadistics/6.2.3_doSaf.sh) - With ANGSD
     * [6.2.4. Convert to Ohana matrix](06_stadistics/6.2.4_calculate_het.sh) - ANGSD & Bash script
   * [6.3. Inbreeding coefficient (FIS)](06_stadistics/) - Using [ngsF-HMM](https://github.com/fgvieira/ngsF-HMM)
     * [6.3.1. Convert to Ohana matrix](06_stadistics/6.3.1_f-HMM.sh) - With ngsF-HMM
   * [6.4. Pairwise FST](06_stadistics/)
     * [6.4.1. Calculate SAF per population (Same as 6.1.1.)](06_stadistics/6.1.1_doSaf.sh) - With ANGSD
     * [6.4.2. Calculate 2D-SFS](06_stadistics/6.4.2_2DSFS.sh) - With ANGSD
     * [6.4.3. Index FST and call realFST](06_stadistics/6.4.3_doSaf.sh) - With ANGSD
     * [6.4.4. Calculated window FST](06_stadistics/6.4.4_FstWindow.sh) - With ANGSD
