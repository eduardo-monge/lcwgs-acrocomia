library(topGO)
library(clusterProfiler)
library(dplyr)
library(ggplot2)
library(clusterProfiler)
library(org.At.tair.db)


#1) topGO
#Read files
g2g <- read.table("gene2go.txt", sep = "\t", stringsAsFactors = FALSE,
                  col.names = c("gene", "go"))
bg_genes <- readLines("background_GO.txt")
fg_genes <- readLines("foreground_GO.txt")

#Select only plant GO termns
plant_go <- AnnotationDbi::select(org.At.tair.db,
                                  keys = keys(org.At.tair.db, "TAIR"),
                                  columns = "GO", keytype = "TAIR")$GO
plant_go <- unique(plant_go[!is.na(plant_go)])
g2g_clean <- g2g %>% filter(go %in% plant_go)
geneID2GO <- split(g2g_clean$go, g2g_clean$gene)
genes_with_go <- names(geneID2GO)
bg_genes <- intersect(bg_genes, genes_with_go)
fg_genes <- intersect(fg_genes, genes_with_go)

#Enrichment analysis
allGenes <- factor(as.integer(bg_genes %in% fg_genes))
names(allGenes) <- bg_genes
stopifnot(sum(allGenes == 1) == length(fg_genes))   # alignment guard

run_go <- function(ontology) {
  GOdata <- new("topGOdata",
                ontology    = ontology,           # "BP","MF","CC"
                allGenes    = allGenes,
                nodeSize    = 5,
                annot       = annFUN.gene2GO,
                gene2GO     = geneID2GO)
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

go_all <- bind_rows(lapply(c("BP","MF","CC"), run_go)) %>%
  filter(Significant >= 2) %>%
  arrange(p)

print(head(go_all %>% filter(p < 0.05), 20))


#Graph
n_fg_go <- length(readLines("foreground_GO.txt")) 
go_plot <- go_all %>%
  mutate(p = suppressWarnings(as.numeric(gsub("[^0-9eE.-]", "", as.character(weight01)))),
         p = ifelse(is.na(p), 1e-30, p),
         GeneRatio = Significant / n_fg_go,
         ontology  = factor(ontology, levels = c("BP","CC","MF"))) %>%
  group_by(ontology) %>%
  slice_min(order_by = p, n = 15, with_ties = FALSE) %>%
  ungroup() %>%
  arrange(ontology, GeneRatio) %>%
  mutate(Term = factor(Term, levels = unique(Term)))

p_go <- ggplot(go_plot, aes(x = GeneRatio, y = Term, fill = p)) +
  geom_col(width = 0.72) +
  facet_grid(ontology ~ ., scales = "free_y", space = "free_y") +
  scale_fill_gradient(low = "red", high = "blue", name = "p-value") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(x = "GeneRatio", y = NULL) +
  theme_bw(base_size = 11) +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor   = element_blank(),
        strip.background    = element_rect(fill = "grey85", color = "grey40"),
        strip.text.y        = element_text(face = "bold"),
        axis.text.y         = element_text(size = 9, color = "black"),
        axis.text.x         = element_text(color = "black"))
p_go


go_bp <- go_plot %>% filter(ontology == "BP")
p_bp <- ggplot(go_bp, aes(x = GeneRatio, y = Term, fill = p)) +
  geom_col(width = 0.72) +
  scale_fill_gradient(low = "red", high = "blue", name = "p-value") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.05))) +
  scale_y_discrete(labels = function(x) stringr::str_wrap(x, width = 40)) +
  labs(x = "GeneRatio", y = NULL) +
  theme_bw(base_size = 11) +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor   = element_blank(),
        axis.text.y         = element_text(size = 9, color = "black"),
        axis.text.x         = element_text(color = "black"))
p_bp

#Buble_Graph
FG_SIZE <- length(intersect(readLines("foreground_GO.txt"), genes_with_go))
go_plot <- go_all %>%
  filter(p < 0.05) %>%
  mutate(GeneRatio = Significant / FG_SIZE,        
         neglog10p = -log10(p),
         ontology  = factor(ontology, levels = c("BP","CC","MF"))) %>%
  group_by(ontology) %>% slice_min(p, n = 10, with_ties = FALSE) %>% ungroup() %>%
  arrange(ontology, GeneRatio) %>%
  mutate(Term = factor(Term, levels = unique(Term)))

p_go <- ggplot(go_plot, aes(x = GeneRatio, y = Term)) +
  geom_point(aes(size = Significant, color = neglog10p)) +
  facet_grid(ontology ~ ., scales = "free_y", space = "free_y") +
  scale_color_gradient(low = "blue", high = "red", name = expression(-log[10](p))) +
  scale_size_continuous(name = "Genes", range = c(2, 8)) +
  scale_y_discrete(labels = function(x) stringr::str_wrap(x, 45)) +
  labs(x = "GeneRatio", y = NULL) +
  theme_bw(base_size = 10) +
  theme(panel.grid.minor = element_blank(),
        strip.text.y = element_text(face = "bold"),
        axis.text = element_text(color = "black"))
p_go

#Just BP
go_plot <- go_all %>%
  filter(p < 0.05, ontology == "BP") %>%
  mutate(GeneRatio = Significant / FG_SIZE,
         neglog10p = -log10(p)) %>%
  slice_min(p, n = 20, with_ties = FALSE) %>%
  arrange(GeneRatio) %>%
  mutate(Term = factor(Term, levels = unique(Term)))

p_go <- ggplot(go_plot, aes(x = GeneRatio, y = Term)) +
  geom_point(aes(size = Significant, color = neglog10p)) +
  scale_color_gradient(low = "blue", high = "red", name = expression(-log[10](p))) +
  scale_size_continuous(name = "Genes", range = c(2, 8)) +
  scale_y_discrete(labels = function(x) stringr::str_wrap(x, 45)) +
  labs(x = "GeneRatio", y = NULL) +
  theme_bw(base_size = 10) +
  theme(panel.grid.minor = element_blank(), axis.text = element_text(color = "black"))
p_go

#2). KEGG 
#Read files
p2g <- read.table("gene2pathway.txt", sep = "\t", stringsAsFactors = FALSE,
                  col.names = c("gene", "path"))
fg_ko <- readLines("foreground_PATH.txt")
bg_ko <- readLines("background_PATH.txt")
#keep plant related genes
drop_ids <- c("map01100","map01110","map01120","map01200","map01210",
              "map01212","map01230","map01232","map01250",
              "map04011","map04013","map03250","map03266",
              "map04933","map01523",
              "map04212","map04550","map04371","map04961")                                    
p2g_clean <- p2g %>%
  filter(!grepl("^map05", path)) %>%        
  filter(!path %in% drop_ids) 
TERM2GENE <- p2g_clean[, c("path", "gene")]
genes_with_path <- unique(p2g_clean$gene)
fg_ko <- readLines("foreground_PATH.txt")
bg_ko <- readLines("background_PATH.txt")

#Enrichment analysis
kegg <- enricher(gene=fg_ko, universe=bg_ko, TERM2GENE=TERM2GENE,
                 pvalueCutoff=1, qvalueCutoff=1,
                 minGSSize=3, maxGSSize=500, pAdjustMethod="BH")
kegg_df <- as.data.frame(kegg) %>% arrange(p.adjust)
head(kegg_df, 20)

#Annotated
kegg_ref <- clusterProfiler::download_KEGG("ko")
path2name <- kegg_ref$KEGGPATHID2NAME
kegg_df <- kegg_df %>%
  mutate(num = gsub("[^0-9]", "", ID)) %>%              
  left_join(
    path2name %>% mutate(num = gsub("[^0-9]", "", as.character(from))),
    by = "num"
  ) %>%
  mutate(Description = ifelse(is.na(to), ID, to)) %>%
  select(-num, -from, -to)

write.csv(kegg_df, "enrichment_KEGG_clusterProfiler.csv", row.names=FALSE)

#Graph
gr_to_num <- function(x) sapply(strsplit(as.character(x), "/"),
                                function(v) as.numeric(v[1]) / as.numeric(v[2]))

kegg_plot <- kegg_df %>%
  mutate(GeneRatio_num = gr_to_num(GeneRatio)) %>%
  slice_min(order_by = p.adjust, n = 15, with_ties = FALSE) %>%
  arrange(GeneRatio_num) %>%
  mutate(Description = factor(Description, levels = unique(Description)))

p_kegg <- ggplot(kegg_plot, aes(x = GeneRatio_num, y = Description, fill = p.adjust)) +
  geom_col(width = 0.72) +
  scale_fill_gradient(low = "red", high = "blue", name = "P.adjust") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(x = "GeneRatio", y = NULL) +
  theme_bw(base_size = 11) +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor   = element_blank(),
        axis.text.y         = element_text(size = 9, color = "black"),
        axis.text.x         = element_text(color = "black"))
p_kegg


#Buble_graph
gr_to_num <- function(x) sapply(strsplit(as.character(x), "/"),
                                function(v) as.numeric(v[1])/as.numeric(v[2]))
kegg_plot <- kegg_df %>%
  filter(pvalue < 0.05) %>%
  mutate(GeneRatio_num = gr_to_num(GeneRatio),
         neglog10p = -log10(pvalue)) %>%
  slice_min(pvalue, n = 30, with_ties = FALSE) %>%
  arrange(GeneRatio_num) %>%
  mutate(Description = factor(Description, levels = unique(Description)))

p_kegg <- ggplot(kegg_plot, aes(x = GeneRatio_num, y = Description)) +
  geom_point(aes(size = Count, color = neglog10p)) +
  scale_color_gradient(low = "blue", high = "red", name = expression(-log[10](p))) +
  scale_size_continuous(name = "Genes", range = c(2, 8)) +
  scale_y_discrete(labels = function(x) stringr::str_wrap(x, 45)) +
  labs(x = "GeneRatio", y = NULL) +
  theme_bw(base_size = 10) +
  theme(panel.grid.minor = element_blank(), axis.text = element_text(color = "black"))

p_kegg
