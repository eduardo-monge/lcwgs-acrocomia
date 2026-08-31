library(tidyverse)
library(reshape2)
library(ggplot2)
library(pheatmap)

#1. Read and filter significant results files
df <- read.table("FinalStats.Observed.txt", header = TRUE)
df$significant <- ifelse(abs(df$Z) > 3, TRUE, FALSE)

#2. Matrix of mean D by population pair
df_pairs <- df %>%
  mutate(pair = paste(pmin(H2, H3), pmax(H2, H3), sep = "_")) %>%
  group_by(pair) %>%
  summarise(meanD = mean(D),
            meanZ = mean(Z),
            nTests = n(),
            sig = any(significant))
df_pairs <- separate(df_pairs, pair, into = c("Pop1","Pop2"), sep = "_")

#Make a matrix
pops <- sort(unique(c(df_pairs$Pop1, df_pairs$Pop2)))
mat <- matrix(NA, nrow = length(pops), ncol = length(pops),
              dimnames = list(pops, pops))

for (i in seq_len(nrow(df_pairs))) {
  p1 <- df_pairs$Pop1[i]
  p2 <- df_pairs$Pop2[i]
  val <- df_pairs$meanD[i]
  mat[p1, p2] <- val
  mat[p2, p1] <- val}
mat[is.na(mat)] <- 0

#heatmap
pheatmap(
  mat,
  color = colorRampPalette(rev(RColorBrewer::brewer.pal(11, "RdBu")))(100),
  border_color = NA,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  display_numbers = FALSE,
  fontsize = 10,
  breaks = seq(-max(abs(mat), na.rm = TRUE),
               max(abs(mat), na.rm = TRUE),
               length.out = 101))
