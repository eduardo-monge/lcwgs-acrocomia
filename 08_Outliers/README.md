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
  * 8.3. GradientForest
    * [8.3.1. Infer previous allel frequencies](8.3.1_do_maf.sh) - With ANGSD
    * [8.3.2. Prior SFS per population](8.3.2_prior_SFS.sh) - With ANGSD
    * [8.3.3. Final allele allel frequencies based on prior SFS](8.3.3_final_SFS.sh) - With ANGSD
    * [8.3.4. Gradient forest analysis per chromosome](8.3.4_gradintforest.R) - With [GradientForest](https://gradientforest.r-forge.r-project.org/biodiversity-survey.pdf) in R. Per chromosome due computational power.
    * [8.3.5. Sperman correlation filter and final enviromental selection](8.3.5_Sperman_correlation.R) - With R
  * 8.4. Baypass
    * [8.4.1. Convert files for chunk analyises](8.4.1_convert.sh) - With bash. Due computanional restrictions
    * [8.4.2. Run core model](8.4.2_core_model.sh) - With ANGSD
    * [8.4.3. Merge XtX across all chunks](8.4.3_merge_xtx.sh) - With ANGSD
    * [8.4.4. POD_calibration](8.4.4_pod.sh) - With ANGSD
    * [8.4.5. BayPass analyses](8.4.5_baypass_maf.sh) - With ANGSD
    * [8.4.6. Call outliers based on XtX POD quantile](8.4.6_out_pod.sh) - With ANGSD
    * [8.4.7. Genome-Environment Association analysis](8.4.7_gea.sh) - With ANGSD
    * [8.4.8. Outleirs based on enviromental variables](8.4.8_out_gea.sh) - With ANGSD
  * 8.5 Concat
