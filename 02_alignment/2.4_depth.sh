#!/bin/bash
#SBATCH --job-name=wgs_process
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=80
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=process.err
#SBATCH --output=process.out

echo "SAMTOOLS VERSION:" >> snp_calling.log
samtools --version >> snp_calling.log

N=8
SAMPLES=$(cat /media/STORAGE/smatheus/wgs/edu/build_loci/processing/samples.txt)

echo "INICIADO EM: "$(date) > snp_calling.log
i=0
for sample in $SAMPLES; do
        echo "INICIANDO SAMTOOLS DEPTH EM: "$(date) >> snp_calling.log
        ((i=i%N)); ((i++==0)) && wait;
        #Depth de sequencias com samtools
        samtools depth -aa /media/STORAGE/smatheus/wgs/edu/build_loci/processing/duplicates/$sample.dedup_clipoverlap.bam \
        | cut -f 3 | gzip > /home/edmonge/wgs_acrocomia/depth/$sample.dedup_clipoverlap.bam.depth.gz &
done && wait;
