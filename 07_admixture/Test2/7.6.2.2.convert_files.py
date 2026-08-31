#!/usr/bin/env python3
"""
0 = Mineiro   1 = Amazonas   2 = Roraima   3 = Intumescens
"""
import os
import numpy as np
from scipy.stats import hypergeom

# Parameters 
INPUT  = "/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test2_Intumescens/Test2_Intu.SFS"
SLURM  = "/home/edmonge/wgs_acrocomia/slurm_scripts/fastsimcoal2/Test2_Intumescens"
MODELS = ["intu_2a","intu_2b","intu_2c","intu_2d","intu_2e", "intu_2f"]

# Sample sizes 
N_MIN  = 18   # 9 diploids
N_AMZ  = 18   # 9 diploids
N_ROR  = 12   # 6 diploids
N_INTU = 16   # 8 diploids

TARGET = 12   # project everything to 12 haploids = 6 diploids (= Roraima)

# Load
print(f"Reading SFS from: {INPUT}")
sfs_flat = np.loadtxt(INPUT)
print(f"Number of values: {len(sfs_flat)}")
expected = (N_MIN + 1) * (N_AMZ + 1) * (N_ROR + 1) * (N_INTU + 1)
print(f"Expected (with monomorphic): {expected}")
assert len(sfs_flat) == expected, f"Size mismatch! Got {len(sfs_flat)}, expected {expected}"

# realSFS flattens with the LAST population (Intumescens) varying fastest
sfs_4d = sfs_flat.reshape(N_MIN + 1, N_AMZ + 1, N_ROR + 1, N_INTU + 1)
print(f"Reshaped to: {sfs_4d.shape}")
print(f"Total sites: {sfs_4d.sum():,.0f}")
print(f"Segregating sites: {sfs_4d.sum() - sfs_4d[0, 0, 0, 0]:,.0f}")

#Hypergeometric projection 
def project_sfs(sfs, target_size, axis):
    current_size = sfs.shape[axis] - 1
    if current_size == target_size:
        return sfs
    proj = np.zeros((target_size + 1, current_size + 1))
    for i in range(current_size + 1):
        for j in range(target_size + 1):
            if j <= i and (target_size - j) <= (current_size - i):
                proj[j, i] = hypergeom.pmf(j, current_size, i, target_size)
    new_sfs = np.tensordot(proj, sfs, axes=([1], [axis]))
    new_sfs = np.moveaxis(new_sfs, 0, axis)
    return new_sfs

print(f"\nProjecting all populations to {TARGET} haploids (= 6 diploids)...")
sfs_proj = project_sfs(sfs_4d,  TARGET, axis=0)   # Mineiro     18 -> 12
sfs_proj = project_sfs(sfs_proj, TARGET, axis=1)  # Amazonas    18 -> 12
sfs_proj = project_sfs(sfs_proj, TARGET, axis=3)  # Intumescens 16 -> 12
# Roraima (axis=2) already at 12, untouched
print(f"Projected shape: {sfs_proj.shape}")
print(f"Total after projection: {sfs_proj.sum():,.1f}")

#Write fsc2 multiSFS obs
def write_msfs(sfs, outfile, sizes):
    with open(outfile, "w") as f:
        f.write("1 observations. No. of demes and sample sizes are on next line\n")
        f.write(f"{len(sizes)} " + " ".join(str(s) for s in sizes) + "\n")
        # C-order flatten = pop0 (Mineiro) outermost, pop3 (Intumescens) fastest
        f.write(" ".join(f"{v:.6f}" for v in sfs.flatten()) + "\n")
    print(f"Wrote: {outfile}  ({sfs.size} values)")

for m in MODELS:
    os.makedirs(f"{SLURM}/{m}", exist_ok=True)
    write_msfs(sfs_proj, f"{SLURM}/{m}/{m}_MSFS.obs", [TARGET, TARGET, TARGET, TARGET])

print("\nDone! All four models share the same observed SFS (13^4 = 28561 values).")
