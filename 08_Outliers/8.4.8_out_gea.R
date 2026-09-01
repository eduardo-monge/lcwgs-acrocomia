.libPaths(c("/home/edmonge/R/x86_64-pc-linux-gnu-library/4.2",
            "/usr/local/lib/R/site-library",
            "/usr/lib/R/site-library","/usr/lib/R/library", .libPaths()))
library(tidyverse)

BASE   <- "/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass"
GEADIR <- file.path(BASE, "GEA")
CHUNKDIR <- file.path(BASE, "chunks")

#Variables
var_names <- readLines(file.path(BASE, "covfiles", "env_all_order.txt"))
stopifnot(length(var_names) == 11)
cat("Covariate order:\n"); print(var_names)
BF_THRESH <- 20
chunk_ids <- sprintf("%04d", 1:180)

assoc_all <- map_dfr(chunk_ids, function(id) {
  betaf <- file.path(GEADIR, paste0("gea_sub", id, "_summary_betai_reg.out"))
  detf  <- file.path(CHUNKDIR, paste0("acrocomia_sub", id, ".snpdet"))
  if (!file.exists(betaf)) { cat("MISSING:", id, "\n"); return(NULL) }

  b <- read.table(betaf, header = TRUE, check.names = FALSE)
  d <- read.table(detf, col.names = c("chr","pos","major","minor"))

  # MRK is the within-chunk SNP index (1..nSNP); map to snp_id via snpdet
  b$snp_id   <- paste(d$chr[b$MRK], d$pos[b$MRK], sep = "_")
  b$variable <- var_names[b$COVARIABLE]
  b$BF       <- b$`BF(dB)`

  b %>%
    filter(BF > BF_THRESH) %>%
    transmute(snp_id, variable, BF,
              Beta = Beta_is, SD_Beta = SD_Beta_is,
              # paper's rule, for the supplementary column
              paper_rule = (abs(Beta_is) - SD_Beta_is) > 0)
})


#Per-variable breakdown
per_var <- assoc_all %>%
  group_by(variable) %>%
  summarise(n_SNPs = n_distinct(snp_id)) %>%
  arrange(desc(n_SNPs))
print(per_var)

#Save
write.csv(assoc_all, file.path(GEADIR, "BayPass_AUX_associations_BF20.csv"),
          row.names = FALSE)
write.csv(per_var, file.path(GEADIR, "BayPass_AUX_per_variable_BF20.csv"),
          row.names = FALSE)

#Build the BayPass GEA union: XtX outliers & AUX-associated
xtx <- read.csv(file.path(BASE, "BayPass_XtX_outliers_POD.csv"))  # 99.5%, 4,133
xtx_ids  <- unique(xtx$snp_id)
aux_ids  <- unique(assoc_all$snp_id)
gea_union <- union(xtx_ids, aux_ids)

writeLines(gea_union, file.path(BASE, "BayPass_GEA_union_99.9.txt"))
saveRDS(list(assoc = assoc_all, per_var = per_var,
             xtx = xtx_ids, aux = aux_ids, union = gea_union),
        file.path(BASE, "BayPass_GEA_union_99.9.rds"))

cat("\nDone.\n")
