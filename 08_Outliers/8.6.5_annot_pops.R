library(topGO)
library(clusterProfiler)
library(dplyr)
library(tidyr)
library(ggplot2)
library(clusterProfiler)
library(org.At.tair.db)

#1) TOP GO
#Read files
g2g <- read.table("gene2go.txt", sep = "\t", stringsAsFactors = FALSE,
                  col.names = c("gene", "go"))
bg_genes <- readLines("background_GO.txt")

#Keep only plants
plant_go <- AnnotationDbi::select(org.At.tair.db,
                                  keys = keys(org.At.tair.db, "TAIR"),
                                  columns = "GO", keytype = "TAIR")$GO
plant_go <- unique(plant_go[!is.na(plant_go)])
g2g_clean     <- g2g %>% filter(go %in% plant_go)
geneID2GO     <- split(g2g_clean$go, g2g_clean$gene)
genes_with_go <- names(geneID2GO)

#Background for all pop
bg_genes <- intersect(bg_genes, genes_with_go)

#Per-population
fg_dir   <- "foreground_back"
fg_files <- list.files(fg_dir, pattern = "_foreground_GO", full.names = TRUE)
pop_names <- sub("_foreground_GO.*$", "", basename(fg_files))

fg_list <- setNames(vector("list", length(fg_files)), pop_names)
for (i in seq_along(fg_files)) {
  fg <- readLines(fg_files[i])
  fg <- intersect(fg, genes_with_go)                 # your original cleaning step
  fg_list[[pop_names[i]]] <- fg
  n_in_bg <- length(intersect(fg, bg_genes))         # report only, no mutation
  cat(sprintf("  %-16s %5d annotated fg genes  (%d in background)\n",
              pop_names[i], length(fg), n_in_bg))
}

#Enrichment analysis
run_go <- function(ontology, allGenes) {
  GOdata <- new("topGOdata",
                ontology = ontology,
                allGenes = allGenes,
                nodeSize = 5,
                annot    = annFUN.gene2GO,
                gene2GO  = geneID2GO)
  res <- runTest(GOdata, algorithm = "weight01", statistic = "fisher")
  tab <- GenTable(GOdata, weight01 = res,
                  orderBy = "weight01", topNodes = length(score(res)),
                  numChar = 1000)
  tab$ontology <- ontology
  tab$p <- suppressWarnings(as.numeric(gsub("[^0-9eE.-]", "", tab$weight01)))
  tab$p[is.na(tab$p)] <- 1e-30
  tab$FDR_BH <- p.adjust(tab$p, method = "BH")
  tab
}

#Loop over populations
go_by_pop <- list()
for (pop in names(fg_list)) {
  fg_genes <- fg_list[[pop]]
  
  allGenes <- factor(as.integer(bg_genes %in% fg_genes))
  names(allGenes) <- bg_genes
  n_in <- sum(allGenes == 1)
  if (n_in != length(fg_genes))
    warning(sprintf("%s: %d/%d fg genes outside background; topGO tests the %d inside",
                    pop, length(fg_genes) - n_in, length(fg_genes), n_in))
  tab <- bind_rows(lapply(c("BP","MF","CC"),
                          function(ont) run_go(ont, allGenes)))
  tab$population <- pop
  go_by_pop[[pop]] <- tab
  cat(sprintf("  [ok] %-14s %d fg genes in universe, %d terms scored\n",
              pop, n_in, nrow(tab)))
}

go_all_pops <- bind_rows(go_by_pop) %>%
  filter(Significant >= 2) %>%
  arrange(population, p)

#Graph heatmap 
make_heatmap <- function(ont) {
  d <- go_all_pops %>% filter(ontology == ont)
  
  # union of top-15 terms (by p) per population
  keep_terms <- d %>%
    group_by(population) %>%
    #filter(p < 0.05) %>% 
    slice_min(order_by = p, n = 6, with_ties = FALSE) %>%
    ungroup() %>%
    distinct(GO.ID, Term)
  
  # full grid: every kept term x every population, fill -log10(p)
  mat <- d %>%
    filter(GO.ID %in% keep_terms$GO.ID) %>%
    mutate(neglog10p = -log10(p)) %>%
    select(Term, population, neglog10p) %>%
    complete(Term = keep_terms$Term,
             population = unique(go_all_pops$population)) %>%
    # order terms by max significance across pops
    group_by(Term) %>% mutate(ord = max(neglog10p, na.rm = TRUE)) %>% ungroup() %>%
    mutate(Term = factor(Term, levels = unique(Term[order(ord)])))
  
  ggplot(mat, aes(x = population, y = Term, fill = neglog10p)) +
    geom_tile(color = "grey90") +
    scale_fill_gradient(low = "blue", high = "red",
                        na.value = "grey95",
                        name = expression(-log[10](p))) +
    scale_x_discrete(position = "top") +
    scale_y_discrete(labels = function(x) stringr::str_wrap(x, 45)) +
    labs(x = NULL, y = NULL, title = ont) +
    theme_minimal(base_size = 10) +
    theme(axis.text.x = element_text(angle = 45, hjust = 0, color = "black"),
          axis.text.y = element_text(size = 8, color = "black"),
          panel.grid  = element_blank(),
          plot.title  = element_text(face = "bold"))
}

for (ont in c("BP")) { #"BP","MF","CC"
  p <- make_heatmap(ont) }
p

#Graph buble
make_bubble <- function(ont) {
  d <- go_all_pops %>% filter(ontology == ont)
  
  keep_terms <- d %>%
    # filter(p < 0.05) %>%
    group_by(population) %>%
    slice_min(order_by = p, n = 7, with_ties = FALSE) %>%
    ungroup() %>%
    distinct(GO.ID, Term)
  
  dd <- d %>%
    filter(GO.ID %in% keep_terms$GO.ID, p < 0.05) %>%   # only sig cells get a bubble
    mutate(neglog10p = -log10(p)) %>%
    group_by(Term) %>% mutate(ord = max(neglog10p)) %>% ungroup() %>%
    mutate(Term = factor(Term, levels = unique(Term[order(ord)])))
  
  ggplot(dd, aes(x = population, y = Term)) +
    geom_point(aes(size = Significant, color = neglog10p)) +
    scale_color_gradient(low = "blue", high = "red",
                         name = expression(-log[10](p))) +
    scale_size_continuous(name = "Genes", range = c(2, 8)) +
    scale_x_discrete(position = "top") +
    scale_y_discrete(labels = function(x) stringr::str_wrap(x, 45)) +
    labs(x = NULL, y = NULL, title = ont) +
    theme_minimal(base_size = 10) +
    theme(axis.text.x = element_text(angle = 45, hjust = 0, color = "black"),
          axis.text.y = element_text(size = 8, color = "black"),
          panel.grid.major = element_line(color = "grey92"),
          plot.title = element_text(face = "bold"))
}

for (ont in c("BP")) {
  p <- make_bubble(ont) }
p


#Buble_vertical
make_bubble <- function(ont) {
  d <- go_all_pops %>% filter(ontology == ont)
  
  keep_terms <- d %>%
    # filter(p < 0.05) %>%
    group_by(population) %>%
    slice_min(order_by = p, n = 10, with_ties = FALSE) %>%
    ungroup() %>%
    distinct(GO.ID, Term)
  
  dd <- d %>%
    filter(GO.ID %in% keep_terms$GO.ID, p < 0.05) %>%   # only sig cells get a bubble
    mutate(neglog10p = -log10(p)) %>%
    group_by(Term) %>% mutate(ord = max(neglog10p)) %>% ungroup() %>%
    mutate(Term = factor(Term, levels = unique(Term[order(ord)])))
  
  ggplot(dd, aes(x = Term, y = population)) +
    geom_point(aes(size = Significant, color = neglog10p)) +
    scale_color_gradient(low = "blue", high = "red",
                         name = expression(-log[10](p))) +
    scale_size_continuous(name = "Genes", range = c(2, 8)) +
    scale_x_discrete(position = "bottom") +
    scale_y_discrete(labels = function(x) stringr::str_wrap(x, 45)) +
    labs(x = NULL, y = NULL) +
    guides(size = guide_legend(label.position = "bottom", nrow = 1)) +
    theme_minimal(base_size = 10) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, color = "black"),
          axis.text.y = element_text(size = 8, color = "black"),
          panel.grid.major = element_line(color = "grey92"),
          legend.position = "bottom",
          legend.box = "horizontal")
}

p <- make_bubble("BP")
p
ggsave("BP_bubble.svg", plot = p,
      device = svglite,        # force the clean vector device
      width = 13, height = 5, units = "in")

#2) KEGG Enrichemt
#Read files and filters for plant-related
p2g <- read.table("gene2pathway.txt", sep = "\t", stringsAsFactors = FALSE,
                  col.names = c("gene", "path"))
drop_ids <- c("map01100","map01110","map01120","map01200","map01210",
              "map01212","map01230","map01232","map01250",
              "map04011","map04013","map03250","map03266",
              "map04933","map01523",
              "map04212","map04550","map04371","map04961", "map04139","map04214","map04721","map04921","map04928",
              "map04666","map01521","map04350","map04392",
              "map04140","map04970","map04217")
p2g_clean <- p2g %>%
  filter(!grepl("^map05", path)) %>%
  filter(!path %in% drop_ids)
TERM2GENE       <- p2g_clean[, c("path", "gene")]
genes_with_path <- unique(p2g_clean$gene)

# background
bg_ko <- intersect(readLines("background_PATH.txt"), genes_with_path)

# per-population foreground
fg_files_ko <- list.files(fg_dir, pattern = "_foreground_PATH", full.names = TRUE)
pop_names   <- sub("_foreground_PATH.*$", "", basename(fg_files_ko))
fg_list_ko  <- setNames(vector("list", length(fg_files_ko)), pop_names)

for (i in seq_along(fg_files_ko)) {
  fg <- intersect(readLines(fg_files_ko[i]), genes_with_path)   # KEGG cleaning
  fg_list_ko[[pop_names[i]]] <- fg
  n_in_bg <- length(intersect(fg, bg_ko))
  cat(sprintf("  %-16s %5d annotated fg genes  (%d in background)\n",
              pop_names[i], length(fg), n_in_bg))
}

#Enrichment analysis
kegg_by_pop <- list()
for (pop in names(fg_list_ko)) {
  fg_ko <- fg_list_ko[[pop]]
  
  kegg <- enricher(gene=fg_ko, universe=bg_ko, TERM2GENE=TERM2GENE,
                   pvalueCutoff=1, qvalueCutoff=1,
                   minGSSize=3, maxGSSize=500, pAdjustMethod="BH")
  
  if (is.null(kegg) || nrow(as.data.frame(kegg)) == 0) {
    cat(sprintf("  [skip] %-14s no pathways enriched\n", pop))
    next
  }
  
  df <- as.data.frame(kegg) %>% mutate(population = pop) %>% arrange(p.adjust)
  kegg_by_pop[[pop]] <- df
  cat(sprintf("  [ok] %-14s %d pathways\n", pop, nrow(df)))
}
kegg_all_pops <- bind_rows(kegg_by_pop)

#Annotated
kegg_ref <- clusterProfiler::download_KEGG("ko")
path2name <- kegg_ref$KEGGPATHID2NAME
kegg_all_pops <- kegg_all_pops %>%
  mutate(num = gsub("[^0-9]", "", ID)) %>%              
  left_join(
    path2name %>% mutate(num = gsub("[^0-9]", "", as.character(from))),
    by = "num"
  ) %>%
  mutate(Description = ifelse(is.na(to), ID, to)) %>%
  select(-num, -from, -to)

#Buble
make_bubble_kegg <- function() {
  d <- kegg_all_pops
  
  keep_terms <- d %>%
    filter(pvalue < 0.05) %>%
    group_by(population) %>%
    slice_min(order_by = pvalue, n = 50, with_ties = FALSE) %>%
    ungroup() %>%
    distinct(ID, Description)
  
  dd <- d %>%
    filter(ID %in% keep_terms$ID, pvalue < 0.05) %>%
    mutate(neglog10p = -log10(pvalue)) %>%
    group_by(Description) %>% mutate(ord = max(neglog10p)) %>% ungroup() %>%
    mutate(Description = factor(Description, levels = unique(Description[order(ord)])))
  
  ggplot(dd, aes(x = population, y = Description)) +
    geom_point(aes(size = Count, color = neglog10p)) +
    scale_color_gradient(low = "blue", high = "red",
                         name = expression(-log[10](p))) +
    scale_size_continuous(name = "Genes", range = c(2, 8)) +
    scale_x_discrete(position = "top") +
    scale_y_discrete(labels = function(x) stringr::str_wrap(x, 45)) +
    labs(x = NULL, y = NULL) +
    theme_minimal(base_size = 10) +
    theme(axis.text.x = element_text(angle = 45, hjust = 0, color = "black"),
          axis.text.y = element_text(size = 8, color = "black"),
          panel.grid.major = element_line(color = "grey92"),
          plot.title = element_text(face = "bold"))
}
p <- make_bubble_kegg()
p
