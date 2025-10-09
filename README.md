# Scripts for Genomic Analyses of *Acrocomia* Species

This repository contains all the Linux and R scripts used to perform the genomic analyses of *Acrocomia* species using low-coverage whole-genome sequencing (lcWGS) data.

## Workflow overview

1. [Pre-processing](01_preprocessing/)

   * [1.1. Demultiplex](01_preprocessing/1.1_demultiplex)
   * [1.2. Created FastQC reportl](01_preprocessing/1.2_fastcq)
   * [1.3. Trimming](01_preprocessing/1.3_trimming)
2. [Alignment and quality filtering](02_alignment/)

   * [2.1. Demultiplex](02_alignment/2.1_aligment)
   * [2.2. Demultiplex](02_alignment/2.2_quality_filters)
   * [2.3. Demultiplex](02_alignment/2.3_depth)
4. [Genotype likelihood estimation (SNP calling)](03_snp_calling/)
5. [Genomic structure analysis](04_structure/)
6. [Demographic analysis](05_demography/)
7. [Selection analysis](06_selection/)
8. [Mitochondrial DNA (mtDNA) analysis](07_mtDNA/)

![Genomic workflow](images/workflow.png)

Each folder includes the corresponding scripts used in the analyses.
No tutorials are provided; this repository serves to ensure full transparency and reproducibility.
