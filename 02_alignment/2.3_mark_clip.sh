#!/bin/bash
#SBATCH --job-name=filter_aligment_acrocomia
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=60
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=mark_dedup.err
#SBATCH --output=marl_dedup.out
N=8
SAMPLES=$(cat /home/edmonge/wgs_acrocomia/samples.txt) #Arquivo de entrada com nome das sequencias
IN="/home/edmonge/wgs_acrocomia/aligment_filtros_semq"
OUT="/home/edmonge/wgs_acrocomia/aligment_clip_semq"
PICARD_PATH="/home/edmonge/wgs_acrocomia/picard.jar"

echo "INICIADO EM: "$(date) > markduplicates.log
#Para cada amostra, realiza os passos seguinte

i=0
for sample in $SAMPLES; do
    echo "CALCULANDO MARKDUPLICATE PARA $sample EM "$(date) >> markduplicates.log
    ((i=i%N)); ((i++==0)) && wait;

    # Mark duplicated
    java -jar $PICARD_PATH MarkDuplicates \
    I=$IN/${sample}.sorted.bam \
    O=$OUT/${sample}.marked.bam \
    M=$OUT/${sample}.duprmmetrics.txt \
    REMOVE_DUPLICATES=true \
    VALIDATION_STRINGENCY=SILENT &
done && wait

i=0
for sample in $SAMPLES; do
        echo "INICIANDO CLIPOVERLAP PARA $sample EM: "$(date) >> markduplicates.log
        ((i=i%N)); ((i++==0)) && wait;

        #Do the clip overlap
        bam clipOverlap \
        --in $OUT/${sample}.marked.bam \
        --out $OUT/${sample}.clip.bam \
        --stats &
done && wait;
