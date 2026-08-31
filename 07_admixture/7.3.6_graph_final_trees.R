#1. Choose best likelihood
library(dplyr)
treedir <- "C:/Users/dumon/OneDrive/Desktop/ESALQ-USP/0. lcWGS/Analyses/D Stadistics and MixTree/Treemix/out_m"
llik_files <- list.files(treedir, pattern = "\\.llik$", full.names = TRUE)

#Take best likelihood 
results <- do.call(rbind, lapply(llik_files, function(f) {
  parts      <- strsplit(basename(f), "\\.")[[1]]
  m_val      <- as.numeric(parts[3])
  lines      <- readLines(f, warn = FALSE)
  final_line <- grep("Exiting", lines, value = TRUE)
  
  if (length(final_line) > 0) {
    lik_val <- as.numeric(tail(strsplit(final_line, " ")[[1]], 1))
    return(data.frame(m = m_val, stem = gsub("\\.llik$", "", basename(f)), likelihood = lik_val))
  }
  return(NULL)
}))
best <- results %>%
  group_by(m) %>%
  slice_max(likelihood, n = 2, with_ties = FALSE) %>%  # <-- add this!
  arrange(m)
print(best)

best_final <- best %>% filter(m %in% c(3, 4))

# 2. Graph
source("plotting_funcs.R")
#Pop orden 
pop_order <- "C:/Users/dumon/OneDrive/Desktop/ESALQ-USP/0. lcWGS/Analyses/D Stadistics and MixTree/Treemix/pop_order.txt"

#Plot automatic 
for (i in 1:nrow(best_final)) {
  m    <- best_final$m[i]
  stem <- file.path(treedir, best_final$stem[i])
  
  # Tree
  plot_tree(stem)
  title(main = sprintf("TreeMix - m=%d (llik=%.3f)", m, best_final$likelihood[i]))
  
  # Residuals - pass file path instead of vector!
  plot_resid(stem, pop_order)
  title(main = sprintf("Residuals - m=%d", m))
}
