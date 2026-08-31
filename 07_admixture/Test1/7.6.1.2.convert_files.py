#!/usr/bin/env python3
import numpy as np
import sys

#Parameters
INPUT = "/home/edmonge/wgs_acrocomia/analyses/fastsimcoal2/Test1_Roraima/Amazonas_Roraima_Sudeste.3dSFS"
OUT_MODEL1A = "/home/edmonge/wgs_acrocomia/slurm_scripts/fastsimcoal2/Test1_Roraima/Model1a/Model1a_DSFS.obs"
OUT_MODEL1B = "/home/edmonge/wgs_acrocomia/slurm_scripts/fastsimcoal2/Test1_Roraima/Model1b/Model1b_DSFS.obs"

# Sample sizes (haploid = 2 × diploid)
N_AMZ = 18   # 9 diploids
N_ROR = 12   # 6 diploids
N_SE  = 22   # 11 diploids

#Load SFS
print(f"Reading SFS from: {INPUT}")
sfs_flat = np.loadtxt(INPUT)
print(f"Number of values: {len(sfs_flat)}")

expected = (N_AMZ + 1) * (N_ROR + 1) * (N_SE + 1)
print(f"Expected (with monomorphic): {expected}")
assert len(sfs_flat) == expected, f"Size mismatch! Got {len(sfs_flat)}, expected {expected}"

#Reshape
sfs_3d = sfs_flat.reshape(N_AMZ + 1, N_ROR + 1, N_SE + 1)
print(f"Reshaped to: {sfs_3d.shape}")
print(f"Total sites: {sfs_3d.sum():,.0f}")
print(f"Segregating sites: {sfs_3d.sum() - sfs_3d[0,0,0]:,.0f}")

#Project to balanced sample sizes
def project_sfs(sfs, target_size, axis):
    """
    Hypergeometric projection of SFS along one axis to a smaller sample size.
    """
    current_size = sfs.shape[axis] - 1
    if current_size == target_size:
        return sfs

    # Build projection matrix
    proj = np.zeros((target_size + 1, current_size + 1))
    for i in range(current_size + 1):
        for j in range(target_size + 1):
            if j <= i and (target_size - j) <= (current_size - i):
                # Hypergeometric probability
                from scipy.stats import hypergeom
                proj[j, i] = hypergeom.pmf(j, current_size, i, target_size)

    # Apply along the specified axis
    new_shape = list(sfs.shape)
    new_shape[axis] = target_size + 1
    new_sfs = np.zeros(new_shape)

    # Reshape for matrix multiplication
    new_sfs = np.tensordot(proj, sfs, axes=([1], [axis]))
    new_sfs = np.moveaxis(new_sfs, 0, axis)

    return new_sfs

print("\nProjecting to balanced sample sizes (n=6 diploids per pop)...")
TARGET = 12  # haploids = 6 diploids

sfs_proj = project_sfs(sfs_3d, TARGET, axis=0)  # Project Amazonas
sfs_proj = project_sfs(sfs_proj, TARGET, axis=2)  # Project Sudeste

print(f"Projected shape: {sfs_proj.shape}")
print(f"Total after projection: {sfs_proj.sum():,.1f}")

#Write fsc2 _DSFS.obs format
def write_dsfs(sfs, outfile, n0, n1, n2):
    """
    Write multi-dimensional SFS in fsc2 _DSFS.obs format.
    Order: pop0 (Amazonas) outermost, pop2 (Sudeste) innermost
    """
    with open(outfile, 'w') as f:
        f.write("1 observations. No. of demes and sample sizes are on next line\n")
        f.write(f"3 {n0} {n1} {n2}\n")
        # Write all values on a single line
        values = []
        for i in range(sfs.shape[0]):       # pop0 (Amazonas)
            for j in range(sfs.shape[1]):    # pop1 (Roraima)
                for k in range(sfs.shape[2]):# pop2 (Sudeste)
                    values.append(f"{sfs[i,j,k]:.6f}")
        f.write(" ".join(values) + "\n")
    print(f"Wrote: {outfile}")

# Write for both models
write_dsfs(sfs_proj, OUT_MODEL1A, TARGET, TARGET, TARGET)
write_dsfs(sfs_proj, OUT_MODEL1B, TARGET, TARGET, TARGET)

print("\nDone!")
