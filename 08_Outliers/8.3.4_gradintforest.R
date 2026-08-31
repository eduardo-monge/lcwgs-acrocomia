# Get chromosome from command line argument
args <- commandArgs(trailingOnly = TRUE)
CHR <- args[1]
cat("Processing chromosome:", CHR, "\n")
cat("Started:", format(Sys.time()), "\n")

# Library paths
.libPaths(c("/home/edmonge/R/x86_64-pc-linux-gnu-library/4.2",
            "/usr/local/lib/R/site-library",
            "/usr/lib/R/site-library",
            "/usr/lib/R/library",
            .libPaths()))

library(tidyverse)
library(gradientForest)
library(parallel)
library(doParallel)

# Parallelization
n_cores <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", unset = 10))
cat("Using", n_cores, "cores\n")
registerDoParallel(cores = n_cores)
options(rf.cores = n_cores, mc.cores = n_cores)

OUTDIR <- "/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest"
POPS   <- c("Mesoamerica", "Costarican", "Roraima", "Amazonas",
            "Sudeste", "Mineiro", "Intumescens", "Totai")
MAF_DIR <- "/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest/final_af_per_pop"

#1. Load SNP matrix for chromosome
cat("Loading MAF files for", CHR, "\n")
freq_list <- lapply(POPS, function(pop) {
  f <- read.table(
    gzfile(file.path(MAF_DIR, paste0(pop, "_freqs.mafs.gz"))),
    header = TRUE
  )
  f$snp_id <- paste(f$chromo, f$position, sep = "_")

  # Keep only this chromosome
  f <- f[f$chromo == CHR, ]
  f <- f[, c("snp_id", "knownEM")]
  colnames(f)[2] <- pop
  return(f)
})

#Keep SNPs present in ALL populations
freq_matrix <- Reduce(function(a, b)
  merge(a, b, by = "snp_id", all = FALSE), freq_list)

rownames(freq_matrix) <- freq_matrix$snp_id
freq_matrix$snp_id <- NULL

cat(CHR, "— SNPs after merging:", nrow(freq_matrix), "\n")

# Transpose
gf_snp_matrix <- t(freq_matrix)

#2. Environmental matrix
env_raw <- read.csv(
  file.path(OUTDIR, "final_environmental_matrix.csv"),
  header = TRUE)
env_raw <- env_raw %>% select(-Lon, -Lat, -Lon.1, -Lat.1)

env_pop <- env_raw %>%
  group_by(Pop) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE)) %>%
  column_to_rownames("Pop")

env_pop <- env_pop[POPS, ]

#3. Run GF for chromosome 
cat("Running GF for", CHR, "at", format(Sys.time()), "\n")

gf_chr <- tryCatch({
  gradientForest(
    data           = cbind(env_pop, gf_snp_matrix),
    predictor.vars = colnames(env_pop),
    response.vars  = colnames(gf_snp_matrix),
    ntree          = 500,
    corr.threshold = 0.5,
    trace          = TRUE
  )
}, error = function(e) {
  cat("ERROR on", CHR, ":", conditionMessage(e), "\n")
  return(NULL)
})

#4. Save results
if (!is.null(gf_chr)) {
  # Save model
  saveRDS(gf_chr,
          file.path(OUTDIR, "chrom_models", paste0("GF_", CHR, ".rds")))

  # Save importance scores
  imp <- importance(gf_chr, type = "Weighted")
  write.csv(
    data.frame(variable = names(imp), importance = imp),
    file.path(OUTDIR, "chrom_models", paste0("GF_", CHR, "_importance.csv")),
    row.names = FALSE
  )

  cat("Finished", CHR, "at", format(Sys.time()), "\n")
} else {
  cat("GF failed for", CHR, "\n")
}
