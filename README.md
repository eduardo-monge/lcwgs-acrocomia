# Scripts for Genomic Analyses of *Acrocomia* Species using lcWGS data

This repository contains all the Linux and R scripts used to perform the genomic analyses of *Acrocomia* species using low-coverage whole-genome sequencing (lcWGS) data.

## Workflow overview

1. [Pre-processing](01_preprocessing/)
2. [Alignment and quality filtering](02_alignment/)
3. [Genotype likelihood estimation (SNP calling)](03_snp_calling/)
4. [LD pruning](04_ld_pruning/)
5. [Genomic structure analysis](05_structure/)
6. [Genomic statics *per* population](06_stadistics/)
7. [Admixture and demographic analysis](07_admixture/)
    * [7.1. PCA](05_structure/)
     *  [1.1.1. Index SNP list](05_structure/5.1.1_index.sh)
     *  [5.1.2. Created LD-pruned beagle](05_structure/5.1.2._ldbeagle.sh)
     *  [5.1.3. Created LD-pruned PCA matrix](05_structure/5.1.3_pcamatrix.sh)
     *  [5.1.4. Graph PCA](05_structure/5.1.4_pcamatrix.R)
     
