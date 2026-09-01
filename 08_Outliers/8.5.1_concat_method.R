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
strict3 <- membership %>% filter(n_methods == 3)  

# Venn diagram
venn <- venn.diagram(
  x = list(BayPass = set_baypass, PCAdapt = set_pcadapt, Ohana = set_ohana),
  category.names = c("BayPass", "PCAdapt", "Ohana"),
  filename = NULL,
  output   = TRUE,
  scaled   = FALSE,          # circulos iguales, no proporcionales al tamano
  euler.d  = FALSE,          # geometria fija simetrica
  col      = "black",        # margen negro
  lwd      = ,              # grosor del borde
  fill     = c("#A1C181", "#9DBAD5", "#F9C74F"),
  alpha    = 0.3,
  cex      = 1.4,            # tamano de los numeros dentro
  cat.cex  = 1.3,            # tamano de los nombres
  margin   = 0.08
)
venn

#7. Write outputs
write.csv(membership, paste0(out_prefix, "_membership_all.csv"), row.names = FALSE)
write.csv(final,      paste0(out_prefix, "_candidates_2of3.csv"), row.names = FALSE)

#8. Write BED
bed <- final %>%
  tidyr::separate(snp, into = c("chrom", "pos"),
                  sep = "_(?=[0-9]+$)", 
                  remove = FALSE) %>%
  mutate(pos   = as.integer(pos),
         start = pos - 1L,
         stop  = pos) %>%
  arrange(chrom, start) %>%        
  select(chrom, start, stop, name = snp)

write.table(bed, paste0(out_prefix, "_candidates.bed"),
            sep = "\t", quote = FALSE,
            row.names = FALSE, col.names = FALSE)  
