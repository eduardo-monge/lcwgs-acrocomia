library(dplyr)
pruned_file <- paste0("/home/edmonge/wgs_acrocomia/analyses/LD_prunning/LDblocks_unlinked_20000.id")
pruned_ids <- readLines(pruned_file)
pruned_positions <- as.integer(sub(".*:", "", pruned_ids))


mafs_file <- paste0("/home/edmonge/wgs_acrocomia/analyses/snp_calling/geno.mafs.gz")
snp_list <- read.table(mafs_file, header=TRUE, stringsAsFactors=FALSE)[,1:4]
pruned_snp_list <- snp_list[snp_list$position %in% pruned_positions, ]
write.table(pruned_snp_list, paste0("/home/edmonge/wgs_acrocomia/analyses/LDpruned.list"), col.names = F, row.names = F, quote = F, sep = "\t")
