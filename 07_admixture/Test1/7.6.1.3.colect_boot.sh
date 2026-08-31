#!/bin/bash
set -euo pipefail

BOOT_DIR="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/bootstrap"
EST_BASE="$BOOT_DIR/02_estimation"
RESULTS="$BOOT_DIR/03_results"

# Number of optimization runs per bootstrap replicate
RUNS_PER_REP=20
mkdir -p "$RESULTS"

# Output file per bootstrap
OUT_FILE="$RESULTS/all_bootstrap_params.txt"

# Get the header from the first available bestlhoods file
HEADER_SRC=$(find "$EST_BASE" -name "Model1b.bestlhoods" -print -quit)
if [[ -z "$HEADER_SRC" ]]; then
    echo "[ERROR] No bestlhoods files found"
    exit 1
fi
head -1 "$HEADER_SRC" | sed 's/^/boot_rep\t/' > "$OUT_FILE"

echo "Collecting best runs per bootstrap replicate..."
N_COMPLETE=0
N_FAILED=0

for boot_rep in $(seq 1 100); do
    BOOT_LIKE_FILE="$RESULTS/boot_${boot_rep}_likelihoods.txt"
    > "$BOOT_LIKE_FILE"

    # Collect lhoods from all runs of this boot rep
    for run in $(seq 1 $RUNS_PER_REP); do
        FILE="$EST_BASE/boot_${boot_rep}/run_${run}/Model1b/Model1b.bestlhoods"
        if [[ -f "$FILE" ]]; then
            awk -v r=$run 'NR==2 {print r"\t"$(NF-1)}' "$FILE" >> "$BOOT_LIKE_FILE"
        fi
    done

    N_RUNS=$(wc -l < "$BOOT_LIKE_FILE")

    if [[ "$N_RUNS" -eq 0 ]]; then
        echo "[WARNING] Boot $boot_rep: no successful runs"
        N_FAILED=$((N_FAILED + 1))
        continue
    fi

    # Find best run (highest MaxEstLhood = least negative)
    BEST_RUN=$(sort -k2 -g -r "$BOOT_LIKE_FILE" | head -1 | awk '{print $1}')
    BEST_FILE="$EST_BASE/boot_${boot_rep}/run_${BEST_RUN}/Model1b/Model1b.bestlhoods"

    # Append best params with boot_rep prefix
    awk -v b=$boot_rep 'NR==2 {print b"\t"$0}' "$BEST_FILE" >> "$OUT_FILE"
    N_COMPLETE=$((N_COMPLETE + 1))
done
