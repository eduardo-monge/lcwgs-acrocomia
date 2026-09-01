.libPaths(c("/home/edmonge/R/x86_64-pc-linux-gnu-library/4.2",
            "/usr/local/lib/R/site-library",
            "/usr/lib/R/site-library",
            "/usr/lib/R/library",
            .libPaths()))
library(tidyverse)

OUTDIR    <- "/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass"
CHUNKDIR  <- file.path(OUTDIR, "chunks")
SEED      <- "5001"

# 1. Merge XtX across all chunks
xtx_files <- list.files(CHUNKDIR,
  pattern = paste0("^core_sub[0-9]+_seed", SEED, "_summary_pi_xtx.out$"),
  full.names = TRUE)
xtx_files <- sort(xtx_files)
cat("XtX files found:", length(xtx_files), "\n")

det_files <- sort(list.files(CHUNKDIR,
  pattern = "^acrocomia_sub[0-9]+\\.snpdet$", full.names = TRUE))
stopifnot(length(xtx_files) == length(det_files))

xtx_all <- map2_dfr(xtx_files, det_files, function(xf, df) {
  x <- read.table(xf, header = TRUE)
  d <- read.table(df, col.names = c("chr","pos","major","minor"))
  stopifnot(nrow(x) == nrow(d))     # row alignment check per chunk
  tibble(snp_id = paste(d$chr, d$pos, sep = "_"),
         chr = d$chr, pos = d$pos,
         M_XtX = x$M_XtX)
})


#2. Log-normal fit on observed XtX
logx <- log(xtx_all$M_XtX)
mu   <- mean(logx); sdev <- sd(logx)
xtx_all$pval <- plnorm(xtx_all$M_XtX, meanlog = mu, sdlog = sdev,
                       lower.tail = FALSE)
xtx_all$outlier <- xtx_all$pval < 0.001

n_out <- sum(xtx_all$outlier)


#3. Save outliers 
write.csv(xtx_all %>% filter(outlier) %>% select(snp_id, chr, pos, M_XtX, pval),
          file.path(OUTDIR, "BayPass_XtX_outliers.csv"), row.names = FALSE)
saveRDS(xtx_all, file.path(OUTDIR, "BayPass_XtX_all.rds"))

#4. observed XtX
thresh <- qlnorm(0.001, meanlog = mu, sdlog = sdev, lower.tail = FALSE)
pdf(file.path(OUTDIR, "Supp_BayPass_XtX_distribution.pdf"), width = 8, height = 5)
hist(xtx_all$M_XtX, breaks = 200, freq = FALSE,
     col = "grey80", border = NA,
     main = "Observed XtX with log-normal threshold",
     xlab = "XtX")
curve(dlnorm(x, meanlog = mu, sdlog = sdev), add = TRUE, lwd = 2)
abline(v = thresh, col = "red", lty = 2)
legend("topright", c("log-normal fit","p<0.001 threshold"),
       lwd = c(2,1), lty = c(1,2), col = c("black","red"), bty = "n")
dev.off()
