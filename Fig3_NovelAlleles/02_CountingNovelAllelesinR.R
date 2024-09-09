setwd("C:/Users/weixuan/Desktop/MoundKeyPopulation/MK_Figures/Fig7_uniqSNPs/")
library(dplyr)
library(tidyr)
library(ggplot2)
library(rmarkdown)

library(UpSetR)

#https://rpubs.com/mchunn/1017151

MK_SNPcount <- read.table(file = "MK_Know_genotypecount3.csv", sep = '\t', head = T)

colnames(MK_SNPcount)


MK_novSNP.cond <- MK_SNPcount %>%
  filter(.,Wild_HomSamplesRef==10) %>%
  filter(.,c(MK_HetSamples  != 0 | MK_HomSamplesAlt != 0)) 

Cu_novSNP.cond <- MK_SNPcount %>%
  filter(.,Wild_HomSamplesRef==10) %>%
  filter(.,c(Cultivar_HetSamples  != 0 | Cultivar_HomSamplesAlt != 0)) 

LR1_novSNP.cond <- MK_SNPcount %>%
  filter(.,Wild_HomSamplesRef==10) %>%
  filter(.,c(Landrace1_HetSamples  != 0 | Landrace1_HomSamplesAlt != 0)) 

LR2_novSNP.cond <- MK_SNPcount %>%
  filter(.,Wild_HomSamplesRef==10) %>%
  filter(.,c(Landrace2_HetSamples  != 0 | Landrace2_HomSamplesAlt != 0)) 

SNPcount <- list("Mound Key" = MK_novSNP.cond$ID, 
                 "Cultivar" = Cu_novSNP.cond$ID, 
                 "Landrace1" = LR1_novSNP.cond$ID,  
                 "Landrace2" = LR2_novSNP.cond$ID)
sapply(SNPcount, length)

sum(table(c(LR1_novSNP.cond$ID, LR2_novSNP.cond$ID))-1)

finalplot <- upset(fromList(SNPcount), point.size = 3, line.size = 1.5,  
                   order.by = c("freq", "degree"), sets.bar.color = "#0073C2FF", 
                   matrix.color = "grey40", main.bar.color	= "grey40", text.scale	= 1,  query.legend = "top",
      queries = list(list(query = intersects, params = list("Mound Key"), color = "black", active = T, query.name = "Mound Key"),
                     list(query = intersects, params = list("Landrace1"), color = "#E69F00", active = T, query.name = "Landrace1"),
                     list(query = intersects, params = list("Landrace2"), color = "#CC79A7", active = T, query.name = "Landrace2"),
                     list(query = intersects, params = list("Cultivar"), color = "#009E73", active = T, query.name = "Cultivar")),
      mainbar.y.label = "Unique/Overlap SNPs",
      sets.x.label = "Non-wild allele")


pdf("Fig4_MK_NewlySNPs.pdf", width = 8, height = 5)
finalplot
dev.off()



##################################################
##################################################
##################################################




