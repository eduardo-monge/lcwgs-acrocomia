#!/bin/bash
set -euo pipefail

BESTRUN="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/Model1b/run_31/Model1b"
BOOT_DIR="/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/bootstrap"

mkdir -p "$BOOT_DIR"
cd "$BOOT_DIR"

# Copy original maxL.par as starting point
cp "$BESTRUN/Model1b_maxL.par" ./Model1b_boot.par

# Modify the file:
sed -i 's|^1 0$|200000 0|' Model1b_boot.par
sed -i 's|^FREQ 1 0 2e-8 OUTEXP$|DNA 100 0 2e-8|' Model1b_boot.par

echo "Created bootstrap par file:"
cat Model1b_boot.par

# Sanity check
if grep -q "^DNA 100 0 2e-8$" Model1b_boot.par; then
    echo "[OK] DNA block correctly set"
else
    echo "[ERROR] sed substitution failed - inspect Model1b_boot.par manually"
    exit 1
fi

if grep -q "^200000 0$" Model1b_boot.par; then
    echo "[OK] Number of loci correctly set to 200000"
else
    echo "[ERROR] sed substitution failed for loci count"
    exit 1
fi
