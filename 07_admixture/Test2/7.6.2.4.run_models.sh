#!/bin/bash

SCRIPT="/home/edmonge/wgs_acrocomia/slurm_scripts/fastsimcoal2/Test2_Intumescens/03_1_Fsc2_array.sh"
LOGS="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test2_Intumescens/logs"
#mkdir -p "$LOGS"   # SLURM will not create the log dir itself

prev=""

for MODEL in intu_2a intu_2b intu_2c intu_2d intu_2e  intu_2f; do
  if [ -z "$prev" ]; then
    jid=$(sbatch --parsable -J "$MODEL" --export=ALL,MODEL="$MODEL" "$SCRIPT")
  else
    jid=$(sbatch --parsable --dependency=afterany:"$prev" \
                 -J "$MODEL" --export=ALL,MODEL="$MODEL" "$SCRIPT")
  fi
  echo "submitted ${MODEL} as job ${jid} (waits for: ${prev:-none})"
  prev="$jid"
done
