#!/usr/bin/env python3
import pandas as pd
import sys

# Usage: python treemix_converter.py file1.mafs.gz file2.mafs.gz ... output_filename
inputs = sys.argv[1:-1]
output = sys.argv[-1]

def load_input(fname):
    print(f"Processing {fname}...")
    # Added compression='gzip' to be safe, though pandas often auto-detects
    df = pd.read_csv(fname, sep='\t', header=0, compression='gzip', usecols=["chromo", "position", "knownEM", "nInd"])

    # === NATURE PAPER METHOD (No Rounding) ===
    # We keep 4 decimal places to save space but keep precision
    # Minor count = 2 * N * Freq
    df["minor"] = (2 * df["nInd"] * df["knownEM"])
    # Major count = 2 * N - Minor
    df["major"] = (2 * df["nInd"] - df["minor"])

    # Name of the column for this population
    # Logic: /path/to/Mesoamerica.mafs.gz -> Mesoamerica
    pop_name = fname.split('/')[-1].split('.')[0]

    # Create the "Major,Minor" string
    # We use f-strings to format floats nicely (e.g., 12.42,1.58)
    df[pop_name] = df.apply(lambda x: f"{x['major']:.3f},{x['minor']:.3f}", axis=1)

    # Keep only chromo, position and the new pop column
    return df[["chromo", "position", pop_name]]

# Load the first one
df = load_input(inputs[0])

# Merge all others
for fname in inputs[1:]:
    df2 = load_input(fname)
    # Inner merge ensures we only keep sites present in ALL populations
    df = pd.merge(df, df2, on=["chromo", "position"], how="inner")

# Check how many SNPs remain
print(f"Total Common SNPs: {len(df)}")

# Remove coordinates and save
df.drop(columns=["chromo", "position"], inplace=True)

# FIXED: Added 'f' before the string and ensured directory exists in your logic
output_path = f"/home/edmonge/wgs_acrocomia/analyses/TreeMix/{output}"

print(f"Saving to {output_path}...")
# Use 'gzip' compression for the output too (TreeMix likes .gz input)
df.to_csv(output_path, sep=" ", index=False, compression='gzip')
print("Done!")
