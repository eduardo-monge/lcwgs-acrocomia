library(dplyr)
library(tidyr)
library(VennDiagram)
library(UpSetR)

#Files
baypass_file <- "BayPass_GEA_union_99.txt"
pcadapt_file <- "outlier_SNP_pcadapt_positions.txt"
ohana_file   <- "ohana_outlier_SNPs_by_pop.txt"

#Organized Ohana
sites_file <- "ohana_sites_ordered.txt"
OHANA_INDEX_BASE <- 1 
out_prefix <- "outlier_intersection_99"

#Read files
clean <- function(x) trimws(gsub("\r$", "", x))

# 2a. BayPass union -> already chr_pos
baypass     <- read.table(baypass_file, header = FALSE, stringsAsFactors = FALSE)
set_baypass <- unique(clean(baypass$V1))

# 2b. PCAdapt -> chr_pos = CHR_BP
pcadapt     <- read.table(pcadapt_file, header = TRUE, sep = "\t",
                          stringsAsFactors = FALSE)
pcadapt$snp <- paste(clean(pcadapt$CHR), clean(pcadapt$BP), sep = "_")
set_pcadapt <- unique(pcadapt$snp)

# 2c. Ohana -> convert snp_index to chr_pos via ordered sites file
sites <- clean(readLines(sites_file))
ohana <- read.table(ohana_file, header = TRUE, sep = "\t",
                    stringsAsFactors = FALSE)
row_id <- ohana$snp_index + (1L - OHANA_INDEX_BASE)
stopifnot(all(row_id >= 1 & row_id <= length(sites)))     
ohana$snp <- sites[row_id]
set_ohana <- unique(ohana$snp)

#Merge thre three methods 
all_snps   <- unique(c(set_baypass, set_pcadapt, set_ohana))
membership <- data.frame(snp = all_snps, stringsAsFactors = FALSE) %>%
  mutate(baypass   = snp %in% set_baypass,
         pcadapt   = snp %in% set_pcadapt,
         ohana     = snp %in% set_ohana,
         n_methods = baypass + pcadapt + ohana)

# Select SNPs in 2 of 3 methods 
final   <- membership %>% filter(n_methods >= 2) %>%
  arrange(desc(n_methods), snp)

#5. Annotate final SNPs with Ohana population(s)
ohana_pop <- ohana %>%
  group_by(snp) %>%
  summarise(ohana_pop = paste(sort(unique(population)), collapse = ";"),
            .groups = "drop")
final <- final %>% left_join(ohana_pop, by = "snp")

ohana_final <- ohana %>% filter(snp %in% final$snp)

#6. Bed per population 
snp_to_bed <- function(snps) {
  tibble(snp = unique(snps)) %>%
    separate(snp, into = c("chrom", "pos"),
             sep = "_(?=[0-9]+$)",   
             remove = FALSE) %>%
    mutate(pos   = as.integer(pos),
           start = pos - 1L,      
           stop  = pos) %>%
    arrange(chrom, start) %>%       
    select(chrom, start, stop, name = snp)
}

pops <- sort(unique(ohana_final$population))
summary_tbl <- tibble(population = character(), n_snps = integer(), file = character())

for (p in sort(unique(ohana_final$population))) {
  snps_p  <- ohana_final %>% filter(population == p) %>% distinct(snp) %>% pull(snp)
  bed_p   <- snp_to_bed(snps_p)
  p_safe  <- gsub("^_|_$", "", gsub("[^A-Za-z0-9]+", "_", p))
  outfile <- paste0(out_prefix, "_", p_safe, "_candidates.bed")
  write.table(bed_p, outfile, sep = "\t", quote = FALSE,
              row.names = FALSE, col.names = FALSE)
  message(sprintf("  [ok]   %-16s %5d SNPs -> %s", p, nrow(bed_p), outfile))
}
