library(tidyverse)
library(ggplot2)
library(ragg)


basedir <- "/home/edmonge/wgs_acrocomia/depth"
bam_list <- read_lines(paste0("/home/edmonge/wgs_acrocomia/samples.txt"))

for (i in 1:length(bam_list)){
  bamfile = bam_list[i]
  # Compute depth stats
  depth <- read_tsv(paste0(basedir, "/", bamfile, ".dedup_clipoverlap.bam.depth.gz"), col_names = F)$X1
  mean_depth <- mean(depth)
  sd_depth <- sd(depth)
  mean_depth_nonzero <- mean(depth[depth > 0])
  mean_depth_within2sd <- mean(depth[depth < mean_depth + 2 * sd_depth])
  median <- median(depth)
  presence <- as.logical(depth)
  proportion_of_reference_covered <- mean(presence)
  output_temp <- tibble(bamfile, mean_depth, sd_depth, mean_depth_nonzero, mean_depth_within2sd, median, proportion_of_reference_covered)
  # Bind stats into dataframe and store sample-specific per base depth and presence data
  if (i==1){
    output <- output_temp
    total_depth <- depth
    total_presence <- presence
  } else {
    output <- bind_rows(output, output_temp)
    total_depth <- total_depth + depth
    total_presence <- total_presence + presence
  }
}

#Save results
output %>%
  mutate(across(where(is.numeric), round, 3))
view(output)
write_csv(output, path="/home/edmonge/wgs_acrocomia/R_scripts/depth_summary.csv")


#Calculated quantile to set min and max depth
quantile<-quantile(total_depth, probs = c(0.01, 0.95, 0.99))
print(quantile)

pdf("/home/edmonge/wgs_acrocomia/R_scripts/plots/depth_percentil.pdf", width = 10, height = 4)
ggplot(data.frame(depth = total_depth), aes(x = depth)) +
  geom_density() +
  geom_vline(xintercept = quantile["99%"], color = "red", linetype = "dashed") +
  labs(x = "Total depth", y = "Density") +
  xlim(0, 380)
dev.off()


# Plot the depth distribution
pdf("/home/edmonge/wgs_acrocomia/R_scripts/plots/depth_distribution_total.pdf", width = 10, height = 4)
tibble(total_depth = total_depth, position = 1:length(total_depth))  %>%
  ggplot(aes(x = position, y = total_depth)) +
  geom_point(size = 0.1)
dev.off()
