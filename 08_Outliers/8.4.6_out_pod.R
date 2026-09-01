.libPaths(c("/home/edmonge/R/x86_64-pc-linux-gnu-library/4.2",
            "/usr/local/lib/R/site-library",
            "/usr/lib/R/site-library",
            "/usr/lib/R/library",
            .libPaths()))
library(tidyverse)

OUTDIR <- "/home/edmonge/wgs_acrocomia/analyses/outliers/BayPass"

#1. Load observed XtX
xtx_all <- readRDS(file.path(OUTDIR, "BayPass_XtX_all.rds"))

#2. POD XtX (the neutral null)
pod <- read.table(file.path(OUTDIR, "pod_calib_large_summary_pi_xtx.out"),
                  header = TRUE)

#3. POD quantile thresholds 
thresholds <- quantile(pod$M_XtX, probs = c(0.99, 0.995, 0.999))
print(round(thresholds, 3))
THRESH <- thresholds["99%"] 

#4. Call outliers
xtx_all$outlier_pod <- xtx_all$M_XtX > THRESH

# Empirical p-value
xtx_all$pval_pod <- sapply(xtx_all$M_XtX, function(x) mean(pod$M_XtX >= x))
n_out <- sum(xtx_all$outlier_pod)

# Counts at each threshold, for reporting
for (nm in names(thresholds)) {
  k <- sum(xtx_all$M_XtX > thresholds[nm])
  cat(sprintf("  %s threshold = %.2f  -> %d outliers (%.4f%%)\n",
              nm, thresholds[nm], k, 100 * k / nrow(xtx_all)))
}

#5. Save
write.csv(xtx_all %>% filter(outlier_pod) %>%
            select(snp_id, chr, pos, M_XtX, pval_pod),
          file.path(OUTDIR, "BayPass_XtX_outliers_POD_99.5.csv"),
          row.names = FALSE)

saveRDS(xtx_all, file.path(OUTDIR, "BayPass_XtX_all_POD_99.5.rds"))


#6. Supplementary plot
pdf(file.path(OUTDIR, "Supp_BayPass_XtX_POD_threshold_99.pdf"),
    width = 8, height = 5)
hist(xtx_all$M_XtX, breaks = 200, freq = FALSE,
     col = rgb(0.6,0.6,0.6,0.5), border = NA,
     main = "Observed vs large POD XtX with POD threshold",
     xlab = "XtX",
     xlim = c(0, quantile(xtx_all$M_XtX, 0.9995)))
hist(pod$M_XtX, breaks = 200, freq = FALSE,
     col = rgb(0.2,0.4,0.8,0.4), border = NA, add = TRUE)
abline(v = THRESH, col = "red", lty = 2, lwd = 2)
legend("topright",
       c("Observed", "POD (neutral)", "POD 99.5% threshold"),
       fill = c(rgb(0.6,0.6,0.6,0.5), rgb(0.2,0.4,0.8,0.4), NA),
       border = NA, lty = c(NA,NA,2), lwd = c(NA,NA,2),
       col = c(NA,NA,"red"), bty = "n")
dev.off()

cat("\nDone.\n")
