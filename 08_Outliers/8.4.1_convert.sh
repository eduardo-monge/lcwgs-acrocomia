#!/bin/bash
#SBATCH --job-name=ConvertByPass
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=10
#SBATCH --time=168:00:00
#SBATCH --mem=200gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/02_ConvertByPass.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/02_ConvertByPass.log

OUTDIR="/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass"
CONVERT="/home/edmonge/wgs_acrocomia/slurm_scripts/outliers/BayPass"
BEAGLE="/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass/full_85_GL.beagle.gz"
HEADER=$(cat $OUTDIR/baypass_header.txt)

mkdir -p $OUTDIR/chunks
cd $OUTDIR/chunks

zcat $BEAGLE | awk -F'\t' \
  -v HEADER="$HEADER" \
  -v CHUNK=100000 \
  -v CAP=99 \
  -v PREFIX=acrocomia_sub \
  -f $CONVERT/beagle2baypass_split.awk
