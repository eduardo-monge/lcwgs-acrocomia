#!/bin/bash
#SBATCH --job-name=filter_aligment_acrocomia
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=100
#SBATCH --time=168:00:00
#SBATCH --mem=400gb
#SBATCH --error=filter.err
#SBATCH --output=filter.out

N=8
SAMPLES=$(cat /home/edmonge/wgs_acrocomia/samples.txt) #Arquivo de entrada com nome das sequencias
SAM="/home/edmonge/wgs_acrocomia/aligment_sem_filtro"
OUT="/home/edmonge/wgs_acrocomia/aligment_filtros_semq"

echo "INICIADO EM: "$(date) > filters.log
#Para cada amostra, realiza os passos seguinte

i=0
for sample in $SAMPLES; do
        echo "INICIANDO BAM FILTERS PARA $sample EM: "$(date) >> filters.log
        ((i=i%N)); ((i++==0)) && wait;
        #Filter and convert to BAM
        samtools view -b -h -F 4 $SAM/${sample}_mapped.sam > $OUT/$sample.bam &
done && wait;

i=0
for sample in $SAMPLES; do
        echo "CREATING SORTED BAM FOR $sample EM "$(date) >> filters.log
        ((i=i%N)); ((i++==0)) && wait;

        #Creando sorted e index
        samtools sort $OUT/$sample.bam -o $OUT/$sample.sorted.bam
        samtools index $OUT/$sample.sorted.bam &
done && wait;

i=0
for sample in $SAMPLES; do
    echo "CALCULANDO FLAGSTAT PARA $sample EM "$(date) >> filters.log
    ((i=i%N)); ((i++==0)) && wait;

    # Calcular estadísticas
    samtools flagstat "$OUT"/${sample}.sorted.bam > "$OUT"/${sample}_flagstat.txt &
done && wait;
