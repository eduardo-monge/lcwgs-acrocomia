library(tidyr)
library(dplyr)
library(UpSetR)

#1. Read files
ohana <- read.table("selscan_K8.txt", header = TRUE, check.names = TRUE)
stopifnot(ncol(ohana) == 4 + 8)
colnames(ohana) <- c("step", "lle_ratio", "global_lle", "local_lle",
                     paste0("f_pop", 0:(8 - 1)))
ohana$snp_index <- seq_len(nrow(ohana))   

#2. Top 1% LLRS outliers
thr      <- quantile(ohana$lle_ratio, 0.99, na.rm = TRUE)
outliers <- subset(ohana, lle_ratio >= thr)

#3. Ancestry -> population map
q   <- as.matrix(read.table("q8_rep18.matrix", skip = 1)) 
pop <- read.table("sample_populations.txt", col.names = c("sample", "population"))

# Q must be samples x K 
if (nrow(q) != nrow(pop) && ncol(q) == nrow(pop)) q <- t(q)
stopifnot(nrow(q) == nrow(pop), ncol(q) == 8)
colnames(q) <- paste0("f_pop", 0:(8 - 1))

mean_q <- aggregate(as.data.frame(q),
                    by = list(population = pop$population), FUN = mean)
anc_to_pop <- sapply(paste0("f_pop", 0:(8 - 1)),
                     function(a) mean_q$population[which.max(mean_q[[a]])])
ancestry_map <- data.frame(ancestry = names(anc_to_pop),
                           population = unname(anc_to_pop),
                           stringsAsFactors = FALSE)
print(ancestry_map)

#4. Attribute SNPs using both conditions
attributed <- outliers %>%
  pivot_longer(starts_with("f_pop"), names_to = "ancestry", values_to = "freq") %>%
  filter(freq > 0.60) %>% #Based on: Chen et al., Sci. Adv. 10, eadh3425 (2024)
  inner_join(ancestry_map, by = "ancestry") %>%    
  distinct(snp_index, population) 

#5. Unique-private
n_pop <- attributed %>% count(snp_index, name = "n_pop")
unique_snps <- attributed %>%
  inner_join(filter(n_pop, n_pop == 1), by = "snp_index") %>%
  select(snp_index, population) %>%
  arrange(population, snp_index)

unique_sets <- split(unique_snps$snp_index, unique_snps$population)

                     
#6. Save
write.table(attributed, "ohana_outlier_SNPs_by_pop.txt",
            quote = FALSE, row.names = FALSE, sep = "\t")
write.table(unique_snps, "ohana_unique_SNPs_by_pop.txt",
            quote = FALSE, row.names = FALSE, sep = "\t")

#7. UpSet of SNP
sets <- split(attributed$snp_index, attributed$population)
upset(fromList(sets), nsets = K, nintersects = 30,
      order.by = "freq", main.bar.color = "black",
      sets.bar.color = "black", text.scale = 1.5)                   
