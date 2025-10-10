
# Genomic structure 
This section is for performing population structure analyses using two different methods: Principal Component Analysis (PCA) and ADMIXTURE to estimate ancestry, both based on LD-pruned SNPs. PCA is performed using [PCANGSD](https://www.popgen.dk/software/index.php/PCAngsd), and ADMIXTURE is run with [Ohana](https://github.com/jade-cheng/ohana).

   * 5.1. PCA
     *  [5.1.1. Index SNP list](5.1.1_index.sh) - With samtools and ANGSD
     *  [5.1.2. Created LD-pruned beagle](5.1.2._ldbeagle.sh)
     *  [5.1.3. Created LD-pruned PCA matrix](5.1.3_pcamatrix.sh)
     *  [5.1.4. Graph PCA](5.1.4_pcamatrix.R)
   * 5.2. ADMIXTURE
     * [5.2.1. Convert to Ohana matrix](5.2.1_convert_ohana.sh)
     * [5.2.2. Run Ohana](5.2.1_convert_ohana.sh)
     * 5.2.3. Choose best K and consensous K matrix with [Clumpak](https://clumpak.tau.ac.il/bestK.html)  

