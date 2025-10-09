library(dplyr)
library(ggplot2)

r <- read.table("/home/edmonge/wgs_acrocomia/analyses/LD_prunning/LDblocks.ld", header=TRUE, stringsAsFactors=FALSE)
bin_size <- 1000
ld_decay <- r %>%
  mutate(bin = (dist %/% bin_size) * bin_size) %>%
  group_by(bin) %>%
  summarise(mean_r2 = mean(r2_ExpG, na.rm = TRUE), .groups = "drop")

p <- ggplot(ld_decay, aes(x = bin, y = mean_r2)) +
  geom_line(color = "blue", linewidth = 1) +
  labs(
    x = "Distance between SNPs (bp)",
    y = expression(Linkage~disequilibrium~(r^2))) +
  scale_x_continuous(breaks = seq(0, 100000, by = 10000)) +
  theme_minimal(base_size = 14)

pdf("/home/edmonge/wgs_acrocomia/R_scripts/plots/LD_decay.pdf", width=8, height=6)
p
dev.off()
