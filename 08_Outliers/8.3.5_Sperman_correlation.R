library(tidyverse)
library(corrplot)

OUTDIR <- "/home/edmonge/wgs_acrocomia/analyses/outliers/gradientForest"
POPS   <- c("Mesoamerica", "Costarican", "Roraima", "Amazonas",
            "Sudeste", "Mineiro", "Intumescens", "Totai")

#1. SNP counts per chromosome
snp_counts <- c(
  chr1  = 1536454, chr2  = 1405842, chr3  = 1316180,
  chr4  = 1201065, chr5  = 1234484, chr6  = 1272763,
  chr7  = 1347183, chr8  = 1319339, chr9  = 1151253,
  chr10 = 1193338, chr11 = 1076107, chr12 = 815182,
  chr13 = 850133,  chr14 = 775812,  chr15 = 601955)

#2. Load importance files
CHROMS <- paste0("chr", c(1:15))

imp_list <- lapply(CHROMS, function(chr) {
  f <- file.path(OUTDIR, "chrom_models",
                 paste0("GF_", chr, "_importance.csv"))
  if (file.exists(f)) {
    cat("Loading:", chr, "\n")
    return(read.csv(f))
  } else {
    cat("MISSING:", chr, "\n")
    return(NULL)
  }
})
names(imp_list) <- CHROMS

loaded <- !sapply(imp_list, is.null)
imp_list <- Filter(Negate(is.null), imp_list)
snp_counts_used <- snp_counts[names(imp_list)]

#3. Weighted average across chromosomes
all_vars <- imp_list[[1]]$variable
imp_merged <- sapply(all_vars, function(var) {
  imp_values <- sapply(imp_list, function(df) {
    df$importance[df$variable == var]
  })
  weighted.mean(imp_values, w = snp_counts_used)
})

#4. Build final importance table
imp_final <- data.frame(
  variable   = names(imp_merged),
  importance = imp_merged) %>%
  arrange(desc(importance)) %>%
  mutate(rank = row_number())

# Fix — remove duplicate variables if any
imp_final <- imp_final[!duplicated(imp_final$variable), ]
print(imp_final)

write.csv(imp_final,
          file.path(OUTDIR, "GF_importance_final_merged.csv"),
          row.names = FALSE)

#5. Importance barplot
p1 <- ggplot(imp_final,
             aes(x = importance,
                 y = reorder(variable, importance))) +
  geom_col(fill = "steelblue", width = 0.7) +
  geom_text(aes(label = rank), hjust = -0.3, size = 3) +
  labs(x        = "Weighted importance",
       y        = "Environmental variable",
       title    = "Gradient Forest - variable importance",
       subtitle = paste0("Merged across ", length(imp_list),
                         " chromosomes | ",
                         format(sum(snp_counts_used), big.mark = ","),
                         " SNPs")) +
  theme_bw() +
  theme(axis.text.y = element_text(size = 10))

print(p1)

ggsave(file.path(OUTDIR, "GF_importance_barplot.pdf"),
       p1, width = 8, height = 6)

#6. Environmental matrix 
env_raw <- read.csv(
  file.path(OUTDIR, "final_environmental_matrix.csv"),
  header = TRUE)

env_raw <- env_raw %>% select(-Lon, -Lat, -Lon.1, -Lat.1)
env_pop <- env_raw %>%
  group_by(Pop) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE)) %>%
  column_to_rownames("Pop")

# Match population order
env_pop <- env_pop[POPS, ]


#7. Correlation heatmap

cor_matrix <- cor(env_pop, method = "spearman")

# Plot 1 — corrplot style
pdf(file.path(OUTDIR, "GF_spearman_correlation_matrix.pdf"),
    width = 12, height = 10)

corrplot(cor_matrix,
         method   = "color",
         type     = "upper",
         order    = "hclust",        # cluster similar variables
         tl.cex   = 0.8,
         tl.col   = "black",
         addCoef.col = "black",      # show correlation values
         number.cex  = 0.6,
         col      = colorRampPalette(c("#2166AC", "white", "#B2182B"))(200),
         title    = "Spearman correlation - environmental variables",
         mar      = c(0, 0, 2, 0))

dev.off()

# Plot 2 — ggplot heatmap
cor_df <- as.data.frame(cor_matrix) %>%
  rownames_to_column("var1") %>%
  pivot_longer(-var1, names_to = "var2", values_to = "r")

p2 <- ggplot(cor_df, aes(x = var1, y = var2, fill = r)) +
  geom_tile(color = "white") +
  geom_text(aes(label = ifelse(abs(r) >= 0.75 & var1 != var2,
                               round(r, 2), "")),
            size = 2.5) +
  scale_fill_gradient2(low  = "#2166AC",
                       mid  = "white",
                       high = "#B2182B",
                       midpoint = 0,
                       limits   = c(-1, 1),
                       name     = "Spearman r") +
  labs(x     = NULL,
       y     = NULL,
       title = "Spearman correlation - environmental variables",
       subtitle = "Values shown where |r| >= 0.75 (collinearity threshold)") +
  theme_bw() +
  theme(axis.text.x  = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y  = element_text(size = 8),
        legend.position = "right")

print(p2)

ggsave(file.path(OUTDIR, "GF_spearman_heatmap.pdf"),
       p2, width = 12, height = 10)

#8 Spearman filtering
ranked_vars <- imp_final$variable  # sorted by importance, no duplicates
keep <- c()
for (var in ranked_vars) {
  if (length(keep) == 0) {
    keep <- c(var)
    cat("Kept (top variable):", var, "\n")
  } else {
    cors <- sapply(keep, function(k) {
      cor(env_pop[, var], env_pop[, k], method = "spearman")
    })
    if (all(abs(cors) < 0.75)) {
      keep <- c(keep, var)
      cat("Kept:", var, "\n")
    } else {
      worst <- keep[which.max(abs(cors))]
      cat("Removed:", var,
          "| |r| =", round(max(abs(cors)), 3),
          "with", worst, "\n")
    }
  }
}

print(keep)
write.csv(data.frame(variable = keep),
          file.path(OUTDIR, "GF_variables_after_spearman.csv"),
          row.names = FALSE)

# Reduced environmental matrix
env_reduced <- env_pop[, keep]
cat("\nFinal environmental matrix dimensions:", dim(env_reduced), "\n")
