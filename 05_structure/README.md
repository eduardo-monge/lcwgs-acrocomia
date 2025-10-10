
# Genomic structure 
This section is for performing population structure analyses using two different methods: Principal Component Analysis (PCA) and ADMIXTURE to estimate ancestry, both based on LD-pruned SNPs. PCA is performed using [PCANGSD](https://www.popgen.dk/software/index.php/PCAngsd), and ADMIXTURE is run with [Ohana](https://github.com/jade-cheng/ohana).

   * 5.1. PCA
     *  [5.1.1. Index SNP list](5.1.1_index.sh) - With samtools and ANGSD
     *  [5.1.2. Created LD-pruned beagle](5.1.2._ldbeagle.sh) - With ANGSD
     *  [5.1.3. Created LD-pruned PCA matrix](5.1.3_pcamatrix.sh) - With PCANGSD
     *  [5.1.4. Graph PCA](5.1.4_pcamatrix.R) - With R
   * 5.2. ADMIXTURE
     * [5.2.1. Convert to Ohana matrix](5.2.1_convert_ohana.sh) - With Ohana
     * [5.2.2. Run Ohana with replicates for each K](5.2.2_ohana.sh) With Ohana
     * 5.2.3. Choose best K and consensous K matrix with [Clumpak](https://clumpak.tau.ac.il/bestK.html) - With Clumpak
     * 5.2.4. Plot the Q matrix following the tutorial: [Make a BGP map](https://eriqande.github.io/make-a-BGP-map/Make-a-BGP-map-Notebook.nb.html)
