#!/bin/bash
#SBATCH --job-name=dopos
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=10
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/statistics/het/dopos.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/statistics/het/dopos.log

LOG="/home/edmonge/wgs_acrocomia/analyses/statistics/het/dopos.log"
MAF="/home/edmonge/wgs_acrocomia/analyses/statistics/het"
ANGSD="/home/edmonge/wgs_acrocomia/programs/angsd/angsd"

#1- Generates a .bed file based on the .mafs file
        echo "Starting .bed in $(date)" >> "$LOG"
        zcat $MAF/globalmaf.mafs.gz | cut -f1,2 | tail -n +2 | awk '{print $1"\t"$2-1"\t"$2}' | bedtools merge -i - \
        > $MAF/global.bed
        echo "Finished .bed in $(date)" >> "$LOG"

#2- Creates a position file based on this new .bed:
        echo "Starting .pos in $(date)" >> "$LOG"
        awk '{print $1"\t"($2+1)"\t"$3}'  $MAF/global.bed > $MAF/global.pos
        echo "Finished .pos in $(date)" >> "$LOG"

#3-Indexs the .pos file created above
        echo "Starting index in $(date)" >> "$LOG"
        $ANGSD sites index $MAF/global.pos
        echo "Finished index in $(date)" >> "$LOG"
