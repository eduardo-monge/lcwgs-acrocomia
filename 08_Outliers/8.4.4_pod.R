.libPaths(c("/home/edmonge/R/x86_64-pc-linux-gnu-library/4.2",
            "/usr/local/lib/R/site-library",
            "/usr/lib/R/site-library",
            "/usr/lib/R/library",
            .libPaths()))
library(tidyverse)

OUTDIR    <- "/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass"
CHUNKDIR  <- file.path(OUTDIR, "chunks")
SEED      <- "5001"  

source("/home/edmonge/wgs_acrocomia/programs/BayPass/utils/baypass_utils.R")
setwd(OUTDIR)

REPCHUNK <- "core_sub0001_seed5001"

omega   <- as.matrix(read.table(file.path(CHUNKDIR,
              paste0(REPCHUNK, "_mat_omega.out"))))
pi.beta <- read.table(file.path(CHUNKDIR,
              paste0(REPCHUNK, "_summary_beta_params.out")),
              header = TRUE)$Mean

# Simulate POD
simu <- simulate.baypass(omega.mat = omega,
                         nsnp = 1000000,
                         beta.pi = pi.beta,
                         pi.maf = 0,
                         suffix = "acrocomia_pod_large")
