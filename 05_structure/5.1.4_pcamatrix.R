library(RcppCNPy)
library(ggplot2)
library(tibble)

cov <- as.matrix(read.table(paste0("PCA_matrix_85.cov"), header = F))
pop <- read.table("pops_85.txt", stringsAsFactors = FALSE)[,1]

mme.pca <- eigen(cov)
eigenvectors = mme.pca$vectors
pca.vectors = as_tibble(cbind(pop, data.frame(eigenvectors)))

pca.eigenval.sum = sum(mme.pca$values) #sum of eigenvalues
varPC1 <- (mme.pca$values[1]/pca.eigenval.sum)*100 #Variance explained by PC1
varPC2 <- (mme.pca$values[2]/pca.eigenval.sum)*100 #Variance explained by PC2
varPC3 <- (mme.pca$values[3]/pca.eigenval.sum)*100 #Variance explained by PC3
varPC4 <- (mme.pca$values[4]/pca.eigenval.sum)*100 #Variance explained by PC4


#Graph with no elipses
shapes <- rep(c(16, 17, 15, 3, 7, 8), length.out = length(unique(pca.vectors$pop)))
shape_map <- setNames(shapes, unique(pca.vectors$pop))

ggplot(pca.vectors, aes(x = X1, y = X2)) +
  geom_point(color = "grey80", size = 2, alpha = 0.5) +
  geom_point(aes(color = pop, shape = pop), size = 3, alpha = 0.9) +
  scale_shape_manual(values = shape_map) +
  labs(
    x = paste0("PC1 (", round(varPC1), "%)"),
    y = paste0("PC2 (", round(varPC2), "%)"),
    color = "Population",
    shape = "Population") +
  theme_classic(base_size = 14) +
  theme(
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.key.size = unit(0.7, "cm"),
    panel.grid = element_line(color = "grey90"),
    axis.title = element_text(size = 10),
    axis.text = element_text(size = 10))


#Grpah with Elipses
my_colors <- c(
  "#E41A1C", # red
  "#377EB8", # blue
  "#4DAF4A", # green
  "#984EA3", # purple
  "#FF7F00", # orange
  "#FFFF33", # yellow
  "#A65628", # brown
  "#F781BF", # pink
  "#999999", # grey
  "#66C2A5", # teal
  "#FC8D62", # salmon
  "#8DA0CB", # light blue
  "#E78AC3", # light pink
  "#A6D854", # lime
  "#D4AF37", # golden
  "#E5C494", # beige
  "#1B9E77", # turquoise
  "#D95F02"  # dark orange/red
)
ggplot(pca.vectors, aes(x = X2, y = X3)) +
  geom_point(aes(color = pop), size = 2.5, alpha = 0.8) +
  stat_ellipse(aes(fill = pop), geom = "polygon", alpha = 0.2, color = NA) +
  scale_color_manual(values = my_colors) +
  scale_fill_manual(values = my_colors)+
  #scale_color_discrete(name = "Population") +
  #scale_fill_discrete(name = "Population") +
  labs(
    x = paste0("PC2 (", round(varPC2), "%)"),
    y = paste0("PC3 (", round(varPC3), "%)")) +
  theme_classic(base_size = 14) +
  theme(
    legend.position = "right",
    legend.direction = "vertical",
    legend.key.size = unit(0.7, "cm"),
    panel.grid = element_line(color = "grey90"),
    axis.title = element_text(size = 10),
    axis.text = element_text(size = 10))
