# Scripts for Genomic Analyses of *Acrocomia* Species using lcWGS data

This repository contains all the Linux and R scripts used to perform the genomic analyses of *Acrocomia* species using low-coverage whole-genome sequencing (lcWGS) data.

## Workflow overview

1. [Pre-processing](01_preprocessing/)
   * [1.1. Demultiplex](01_preprocessing/1.1_demultiplex)
   * [1.2. Created FastQC report](01_preprocessing/1.2_fastcq)
   * [1.3. Trimming](01_preprocessing/1.3_trimming)
2. [Alignment and quality filtering](02_alignment/)
   * [2.1. Aligment](02_alignment/2.1_aligment)
   * [2.2. Quality filters](02_alignment/2.2_quality_filters.sh)
   * [2.3. MarkDuplicates & ClipOverlap](02_alignment/2.3_mark_clip.sh)
   * [2.4. Calculated mean depth](02_alignment/2.4_depth.sh)
   * [2.5. Computated depth and statics in R](02_alignment/2.5.statics.R)
       
3. [Genotype likelihood estimation (SNP calling)](03_snp_calling/)
   * [3.1. Created BAM list](03_snp_calling/3.1_bamlist)
   * [3.2. Calculated Genotype Likelihood (GL)](03_snp_calling/3.1_genolike.sh)
4. [LD pruning](04_ld_pruning/)
   * [4.1. Convert beagle file](04_ld_pruning/4.1_convert_beagle.sh)
   * [4.2. Calculated LD](04_ld_pruning/4.2_calculated_LD.sh)
   * [4.3. Graph LD](04_ld_pruning/4.3_Graph_LD.R)
   * [4.4. Perform SNP pruning](04_ld_pruning/4.4_pruning.sh)
   * [4.5. Created LD-prunned file for PCA](04_ld_pruning/4.5_file_for_pca.R)
5. [Genomic structure analysis](05_structure/)
   * [5.1. PCA](05_structure/)
     *  [5.1.1. Index SNP list](05_structure/5.1.1_index.sh)
     *  [5.1.2. Created LD-pruned beagle](05_structure/5.1.2._ldbeagle.sh)
     *  [5.1.3. Created LD-pruned PCA matrix](05_structure/5.1.3_pcamatrix.sh)
     *  [5.1.4. Graph PCA](05_structure/5.1.4_pcamatrix.R)
   * [5.2. ADMIXTURE](05_structure/)
     * [5.2.1. Convert to Ohana matrix](05_structure/5.2.1_convert_ohana.sh)
     * [5.2.2. Run Ohana with replicates for each K](05_structure/5.2.1_convert_ohana.sh)
     * 5.2.3. Choose best K and consensous K matrix with [Clumpak](https://clumpak.tau.ac.il/bestK.html)
     * 5.2.4. Plot the Q matrix following the tutorial: [Make a BGP map](https://eriqande.github.io/make-a-BGP-map/Make-a-BGP-map-Notebook.nb.html)   
     
X. [Genomic statics *per* population](04_structure/)
X. [Demographic analysis](05_demography/)
X. [Selection analysis](06_selection/)
X. [Mitochondrial DNA (mtDNA) analysis](07_mtDNA/)

![Genomic workflow](images/workflow.png)

Each folder includes the corresponding scripts used in the analyses.
No tutorials are provided; this repository serves to ensure full transparency and reproducibility.
