#!/bin/bash
#SBATCH --job-name=convert_rev
#SBATCH --partition=bigmem
#SBATCH --ntasks-per-node=20
#SBATCH --time=168:00:00
#SBATCH --mem=100gb
#SBATCH --error=/home/edmonge/wgs_acrocomia/analyses/revbayes/01_convert.log
#SBATCH --output=/home/edmonge/wgs_acrocomia/analyses/revbayes/01_convert.log

LOG="/home/edmonge/wgs_acrocomia/analyses/revbayes/01_convert.log"
SFS="/home/edmonge/wgs_acrocomia/analyses/statistics/realSFS"
DATA="/home/edmonge/wgs_acrocomia/analyses/revbayes"

declare -A N_IND
N_IND["Amazonas"]=18
N_IND["Costarican"]=34
N_IND["Intumescens"]=16
N_IND["Mesoamerica"]=36
N_IND["Mineiro"]=18
N_IND["Roraima"]=12
N_IND["Sudeste"]=22
N_IND["Totai"]=14

mkdir -p "$DATA/data"

for POP in Amazonas Costarican Intumescens Mesoamerica Mineiro Roraima Sudeste Totai; do
    SFS_FILE="$SFS/${POP}.sfs"
    OUT_FILE="$DATA/data/${POP}_data.Rev"
    SFS_VALUES=$(cat "$SFS_FILE" | tr ' ' '\n' | awk '{printf "%d\n", $1}' | tr '\n' ',' | sed 's/,$//')
    cat > "$OUT_FILE" << EOF
# Auto-generated data file for ${POP}
POP_NAME = "${POP}"
N_IND    = ${N_IND[$POP]}
obs_sfs  = [ ${SFS_VALUES} ]
EOF

    echo "Created: $OUT_FILE" >> "$LOG"
done

echo "All data files generated!" >> "$LOG"
