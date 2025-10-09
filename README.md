# Scripts for Genomic Analyses of *Acrocomia* Species

This repository contains all the Linux and R scripts used to perform the genomic analyses of *Acrocomia* species using low-coverage whole-genome sequencing (lcWGS) data.

## Workflow overview

1. [Pre-processing](01_preprocessing/)

   * [1.1 Demultiplex](01_preprocessing/1.1_demultiplex)
   * [1.2 Quality control](01_preprocessing/1.2_fastcq)
   * [1.3 Filtering](01_preprocessing/1.3_trimming)
2. [Alignment](02_alignment/)
3. [Genotype likelihood estimation (SNP calling)](03_snp_calling/)
4. [Genomic structure analysis](04_structure/)
5. [Demographic analysis](05_demography/)
6. [Selection analysis](06_selection/)
7. [Mitochondrial DNA (mtDNA) analysis](07_mtDNA/)

![Genomic workflow](images/workflow.png)

Each folder includes the corresponding scripts used in the analyses.
No tutorials are provided; this repository serves to ensure full transparency and reproducibility.
