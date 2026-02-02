# Admixture and demographic Analysis 
Here are the scripts for performing analyses related to admixture processes (allele exchange) and changes in population demographics. 

   * 7.1. Distance-based phylogeny
       *  [7.1.1. Estimate pairwise genetic distances](7.1.1_doSaf.sh) - With [ngsDist](https://github.com/fgvieira/ngsDist?tab=readme-ov-file)
       *  [7.1.2. Wstimate the distance-based phylogeny using BioNJ](7.1.2._realSFS.sh) - With [FastME](http://atgc.lirmm.fr/fastme/)
       *  [7.1.3. Place supports on the final tree](7.1.3_calculates_theta.sh) - With [RAxML-NG](https://github.com/amkozlov/raxml-ng)
   * 7.2. D statistics (ABBA-BABA test) (Ho)
     * [7.2.1. Calculated MAF file per population](7.2.1_callmaf.sh) - With ANGSD
     * [7.2.2. Run the Abbababa2](7.2.2_create_pos.sh)  - With ANGSD
   * 7.3. TreeMix
     * [7.3.1. Stimate MAF file per population](7.3.1_f-HMM.sh) - With ANGSD
     * [7.3.2. Converted to TreeMix](7.3.1_f-HMM.sh) - Using the scrip by [Rocha et al.](https://github.com/joanocha/ngsIntrogression/blob/master/input_for_treemix.py)
     * [7.3.3. Run TreeMix with replciates](7.3.1_f-HMM.sh)- With Treeemix
     * [7.3.4. Graph the likelihood for each replciate](7.3.1_f-HMM.sh) - With R
   * 7.4. LD Decay
     * [7.4.1. Call the GL per population ](7.1.1_doSaf.sh) - With ANGSD
     * [7.4.2. Calculate LD](7.4.2_2DSFS.sh) - With [ngsLD](https://github.com/fgvieira/ngsLD/tree/master)
