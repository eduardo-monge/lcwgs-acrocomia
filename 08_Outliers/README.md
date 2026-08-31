# Detection of putative outlier SNPs  
Here are the scripts for performing analyses related the three methods for detection of SNPs outleirs and their functional annotation

  * 8.1. pcadapt
    *  [8.1.1. Run pcadapt with 5 PCA](8.1.1_run_pcadapt.sh) - With [pcangsd](https://www.popgen.dk/software/index.php/PCAngsd)
    *  [8.1.2. Convert Zscore values](8.1.2_convert_pcadapt.sh) - With the [pcadapt.R](https://github.com/Rosemeis/pcangsd/blob/1f1052f4d36dc3bfbce58b1af5db5e9bc3c61f70/scripts/pcadapt.R) from pcangsd
    *  [8.1.3. Select outleirs](8.1.3_select_out_pcadapt.R) - With R
  * 8.2. Ohana
    *  [8.2.1. Admixture-corrected allele frequencies (f-matrox)](8.2.1_f_matrix.sh) - With Ohana
    *  [8.2.2. Run pcadapt with 5 PCA](8.2.2_selscan.sh) - With Ohana
    *  [8.2.3. Per-population outliers SNPs](8.2.3_select_outliers.R) - With R. Based on [Chen et al. (2024)](https://www.science.org/doi/10.1126/sciadv.adh3425)
  * 8.3. RandomForest
  * 8.4. BayPass
  * 8.5 Concat
