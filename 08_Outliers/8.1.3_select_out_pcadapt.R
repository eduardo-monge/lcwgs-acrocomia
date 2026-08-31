#1. Parameters 
K     <- 5      # number of PCs used in the scan (pcangsd -e 5)
alpha <- 0.10   # BH-FDR threshold for calling outlier
test_file  <- "NA.pcadapt.test.txt"   # raw Mahalanobis distances (d2), 1 per kept site
pval_file  <- "NA.pcadapt.pval.txt"   # uncorrected p-values from pcadapt.R (cross-check only)
pos_file   <- "chr_pos.txt"           # CHR BP for EVERY site in the beagle (pre-filter)
sites_file <- "PCAngsd.sites"         # 0/1 keep mask from --sites-save


#1. Genomic-inflation correction 
d2 <- read.table(test_file)[, 1]
cat("Sites in .test file:", length(d2), "| NA d2:", sum(is.na(d2)), "\n")

# genomic inflation factor on the correct distribution (chi-square, df = K)
gif   <- median(d2, na.rm = TRUE) / qchisq(0.5, df = K)
pvals <- pchisq(d2 / gif, df = K, lower.tail = FALSE)
cat("Genomic inflation factor (gif):", round(gif, 3), "\n")

# sanity check: lambda recomputed on corrected p-values should be ~1
lambda_after <- median(qchisq(pvals, df = K, lower.tail = FALSE), na.rm = TRUE) /
  qchisq(0.5, df = K)
cat("Lambda after correction:", round(lambda_after, 3), "\n")

# cross-check that .test and .pval come from the same run (same length)
pvals_raw <- read.table(pval_file)[, 1]
stopifnot(length(pvals_raw) == length(d2))


#2. Positions, alignment checks, outlier calling
positions  <- read.table(pos_file, header = FALSE, col.names = c("CHR", "BP"))
kept_sites <- read.table(sites_file)[, 1]

#Critical alignment checks: stop if inputs don't match
stopifnot(nrow(positions) == length(kept_sites))      # both = total beagle sites
positions_filtered <- positions[kept_sites == 1, ]
stopifnot(nrow(positions_filtered) == length(pvals))  # kept sites = # of p-values

# main data frame
gwas_data <- data.frame(
  CHR = positions_filtered$CHR,
  BP  = positions_filtered$BP,
  P   = pvals
)
gwas_data$CHR_NUM <- as.numeric(as.factor(gwas_data$CHR))
gwas_data$logP    <- -log10(gwas_data$P)

# BH / FDR correction (order-independent)
gwas_data$padj       <- p.adjust(gwas_data$P, method = "BH")
gwas_data$is_outlier <- !is.na(gwas_data$padj) & gwas_data$padj < alpha

# report
n_snps     <- nrow(gwas_data)
n_outliers <- sum(gwas_data$is_outlier)
cat("Total SNPs tested:", n_snps, "\n")
cat("Outliers (BH-FDR <", alpha, "):", n_outliers,
    sprintf("(%.3f%% of genome)\n", 100 * n_outliers / n_snps))


#3. Plots
# order by chromosome then position (for the Manhattan plot)
gwas_data <- gwas_data[order(gwas_data$CHR_NUM, gwas_data$BP), ]

#(A) Histogram of corrected p-values
hist(gwas_data$P, breaks = 50, col = "grey",
     xlab = "Corrected p-value",
     main = "Distribution of gif-corrected p-values")

# (B) Q-Q plot
obs <- sort(-log10(gwas_data$P))
exp <- sort(-log10(ppoints(length(obs))))
plot(exp, obs, pch = 20, col = "darkblue", cex = 0.8,
     xlab = "Expected -log10(p)", ylab = "Observed -log10(p)",
     main = paste0("Q-Q plot (gif = ", round(gif, 2), ")"))
abline(0, 1, col = "red", lwd = 2)

#(C) Manhattan plot 
chr_lengths <- tapply(gwas_data$BP, gwas_data$CHR_NUM, max)
chr_starts  <- c(0, cumsum(chr_lengths)[-length(chr_lengths)])
gwas_data$CUM_POS <- gwas_data$BP + chr_starts[gwas_data$CHR_NUM]

cols <- ifelse(gwas_data$CHR_NUM %% 2 == 0, "darkblue", "orange")
cols[gwas_data$is_outlier] <- "red"

plot(gwas_data$CUM_POS, gwas_data$logP, pch = 20, cex = 0.8, col = cols,
     xaxt = "n", xlab = "Chromosome", ylab = "-log10(corrected p)",
     main = paste0("PCAdapt selection scan (", n_outliers,
                   " outliers, BH-FDR < ", alpha, ")"))
axis_pos <- tapply(gwas_data$CUM_POS, gwas_data$CHR_NUM, mean)
axis(1, at = axis_pos, labels = unique(gwas_data$CHR), cex.axis = 0.7)

# FDR threshold line (only if there is at least one outlier)
if (n_outliers > 0) {
  thr <- min(gwas_data$logP[gwas_data$is_outlier])
  abline(h = thr, col = "red", lty = 2, lwd = 1.5)
}


#4. Save outputs
outlier_table <- gwas_data[gwas_data$is_outlier,
                           c("CHR", "BP", "P", "padj", "logP")]
names(outlier_table) <- c("CHR", "BP", "P_corrected", "P_adjusted_BH", "logP")
outlier_table <- outlier_table[order(outlier_table$P_corrected), ]

# full outlier list
write.table(outlier_table, "outlier_SNP_pcadapt_positions.txt",
            quote = FALSE, row.names = FALSE, col.names = TRUE, sep = "\t")

# simple CHR/BP list for ANGSD filtering
write.table(outlier_table[, c("CHR", "BP")], "outlier_sites_ANGSD.txt",
            quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")

# outlier distribution across chromosomes
print(table(outlier_table$CHR))
