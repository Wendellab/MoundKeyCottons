setwd(getwd())

library(gridExtra)
library(tidyverse)
library(ggpubr)
library(ggrepel)
library(grid)
library(ggplot2)
library(ape)
library(ggtree)
library(treeio)

#######################################################################
### PCA ###############################################################
#######################################################################

cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73",  "#0072B2", "#D55E00", "#CC79A7")

pca <- read_table("MK_Known_n65.eigenvec", col_names = FALSE)
eigenval <- scan("MK_Known_n65.eigenval")

pca <- pca[,-1]
pve <- data.frame(PC = 1:length(eigenval), pve = eigenval/sum(eigenval)*100)

a <- ggplot(pve, aes(PC, pve)) + geom_bar(stat = "identity")
a + ylab("Percentage variance explained") + theme_light()

# set names
names(pca)[1] <- "ind"
names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))
pca$Population <- stringr::str_extract(pca$ind, "[^_]*")
pca$Population <- gsub("MKSite.*","Mound Key",pca$Population )
#pca$population <- gsub("AD.*","outgroup",pca$population )

#options(ggrepel.max.overlaps = Inf)
unique(pca$Population)

library(plotly)
library(stats)
fig <- plot_ly(pca, x = ~PC1, y = ~PC2, z = ~PC3, color = ~pca$Population) 
fig <- fig %>%
  layout(scene = list(bgcolor = "#e5ecf6"))


pca_plot <- ggplot(pca, aes(PC1, PC2, col = Population, shape = Population)) + geom_point(size = 4) + 
   geom_text_repel(data=pca[pca$ind == "Landrace1_B12BPS1238",], aes(label= ind, col = Population),  size = 3, segment.alpha =1, show.legend = F) +
#  ggtitle("Genic SNPs variation \n11,408 filtered SNPs across 100 individuals \n--geno 0 --indep-pairwise 50 10 0.1") +
  xlab(paste0("PC1 (", signif(pve$pve[1], 3), "%)")) + ylab(paste0("PC2 (", signif(pve$pve[2], 3), "%)")) +
  scale_color_manual(values=c("Mound Key"= "black",
                              "Wild" = "#0072B2",
                              "Landrace1" = "#E69F00",
                              "Landrace2" = "#CC79A7",
                              "Cultivar" = "#009E73")) +
  theme_bw() +  
  theme(legend.position =  c(0.13, 0.8),
        #legend.title=element_blank(),
        legend.key = element_rect(fill = "white", colour = "grey30", linetype="dotted")) 

pca_plot$labels$colour <- "Population/Group"
pca_plot$labels$shape <- "Population/Group"

#######################################################################
### LEA ###############################################################
#######################################################################
load("LEAstruture_n65.RData")

plot_list <- readRDS("plotlist_n65.RData")

plot_list[[1]]$data$individual <- gsub("MK","MoundKey",plot_list[[1]]$data$individual)
plot_list[[2]]$data$individual <- gsub("MK","MoundKey",plot_list[[2]]$data$individual)


LEA_k3 <- plot_list[[1]] +
  # some formatting details to make it pretty
  theme(axis.text.x = element_blank())

LEA_k4 <- plot_list[[2]] +
  # some formatting details to make it pretty
  theme(axis.text.x = element_text(angle = -90, hjust= 0.01, vjust=0.5))

ggarrange(LEA_k3, LEA_k4, nrow = 2)

library(grid)
library("ggplotify")
#https://felixfan.github.io/stacking-plots-same-x/
#https://cran.r-project.org/web/packages/ggplotify/vignettes/ggplotify.html
grid.newpage()
LEA_k3_k4 <- as.ggplot(rbind(ggplotGrob(LEA_k3), ggplotGrob(LEA_k4), size = "last"))

#######################################################################
### Phylogeny #########################################################
#######################################################################


MK_dis <- as.matrix(read.table("MK_Known_n65-pruned.distmatrix", row.names = 2)[-1])
MK_distree <- nj(MK_dis)

MK_distree2 <- as.tibble(MK_distree) %>% 
  mutate(Population = gsub("_.*", "", label)) %>%
  mutate(Population = gsub("MKSite.*", "Mound Key", Population)) %>%
  as.treedata()


MKnjtree <- ggtree(MK_distree2, aes(color=Population), size = 0.9, layout="equal_angle", show.legend = F) +
  geom_tippoint(aes(shape=Population), size=4) +
  scale_color_manual(values=c("Mound Key"= "black",
                              "Wild" = "#0072B2",
                              "Landrace1" = "#E69F00",
                              "Landrace2" = "#CC79A7",
                              "Cultivar" = "#009E73")) +
  theme(legend.position =  c(0.75, 0.17),
        #legend.title=element_blank(),
        legend.key = element_rect(fill = "white", colour = "grey30", linetype="dotted")) +
  annotate("text", x = -0.25, y = 0.028, label= "Landrace1_B12BPS1238", size = 3, color = "#E69F00")

MKnjtree$labels$colour <- "Population/Group"
MKnjtree$labels$shape <- "Population/Group"


MKnjtree_sup <- ggtree(MK_distree2, aes(color=Population), size = 0.9, layout="equal_angle", show.legend = F) +
  geom_tippoint(aes(shape=Population), size=4, show.legend = F) +
  geom_text(aes(label=label), size = 2, show.legend = F, vjust = -0.9)+
  scale_color_manual(values=c("Mound Key"= "black",
                              "Wild" = "#0072B2",
                              "Landrace1" = "#E69F00",
                              "Landrace2" = "#CC79A7",
                              "Cultivar" = "#009E73")) 

#######################################################################
### Put it together ###################################################
#######################################################################

library("cowplot")

finalplot <- ggdraw() +
  draw_plot(pca_plot, x = 0, y = .5, width = .5, height = .5) +
  draw_plot(MKnjtree, x = .5, y = .5, width = .5, height = .5) +
  draw_plot(LEA_k3_k4, x = 0, y = 0, width = 1, height = 0.5) +
  draw_plot_label(label = c("A", "B", "C"), size = 15,
                  x = c(0, 0.5, 0), y = c(1, 1, 0.5))


pdf("Fig2_MK_PopStructure_n65.pdf", width = 13, height = 10)
finalplot
dev.off()
