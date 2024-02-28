setwd("C:/Users/weixuan/Desktop/MoundKeyPopulation/MK_Figures/Fig5_fst_dxy_LD/")
library(stringr)
library(dplyr)
library(grid)   # for the textGrob() function
library(ggpubr)
library(ggplot2)
library(scales)
library(reshape2)
library(pheatmap)
library("cowplot")

cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73",  "#0072B2", "#D55E00", "#CC79A7")

#######################################################################
### Pi ###############################################################
#######################################################################

inp.pi <-read.table("MK_Known_n65_pi.txt",sep="\t",header=T)
chrOrder <- sort(unique(inp.pi$chromosome))
inp.pi$chrOrder <- factor(inp.pi$chromosome,levels=chrOrder)

inp.pi.avg <- inp.pi %>%
  group_by(pop, chromosome) %>% 
  dplyr::summarize(Avg_pi = mean(avg_pi, na.rm=TRUE)) 
#%>%
#  mutate(Group = gsub("[0-9]", "", chromosome))  %>%
#  group_by(pop, Group) %>% 
#  dplyr::summarize(Avg_pi_chrom = mean(Avg_pi, na.rm=TRUE)) 

colnames(inp.pi.avg)[1] <- "Accession"

inp.pi.avg$Accession <- gsub("MK", "Mound Key", inp.pi.avg$Accession)

inp.pi.avg.mean <- inp.pi.avg %>%
  group_by(Accession) %>% 
  dplyr::summarize(Avg = mean(Avg_pi, na.rm=TRUE)) %>%
  as.data.frame()

plot.inp.pi.avg <- ggplot() +
  geom_point(data = inp.pi.avg, aes(x=chromosome, y=Avg_pi, color = Accession, shape = Accession), size = 2, show.legend = F) +
  scale_color_manual(values=c("Mound Key"= "black",
                              "Wild" = "#0072B2",
                              "Landrace1" = "#E69F00",
                              "Landrace2" = "#CC79A7",
                              "Cultivar" = "#009E73"))+
  facet_grid(. ~ Accession) +
  geom_hline(data = inp.pi.avg.mean, aes(yintercept = Avg), color = "blue", show.legend = F) +
  ylab("Avg Pi / Chromsome")+
#  xlab("Chromsome")+
#  scale_y_continuous(labels = scales::scientific) + 
  theme_minimal() +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_text(angle = -90, vjust = 0.5, hjust=1, size = 4))

plot.inp.pi.avg


#######################################################################
#######################################################################
### Dxy & Fst #########################################################
#https://stackoverflow.com/questions/41764818/ggplot2-boxplots-with-points-and-fill-separation
#######################################################################

inp.dxy <-read.table("MK_Known_n65_dxy.txt",sep="\t",header=T)
chrOrder <- sort(unique(inp.dxy$chromosome))
inp.dxy$chrOrder <- factor(inp.dxy$chromosome,levels=chrOrder)
inp.dxy$Group <- str_c(inp.dxy$pop1, "_", inp.dxy$pop2)

inp.dxy.avg <- inp.dxy %>%
  #  filter(.,c(pop1 == "MK" | pop2 == "MK")) %>%
  #  filter(.,pop1 %in% c("MoundKeyPop1", "MoundKeyPop2")) %>%
  group_by(pop1, pop2, chromosome, Group) %>%
  dplyr::summarize(Mean = mean(avg_dxy, na.rm=TRUE)) %>%
  as.data.frame()



inp.dxy.avg$Group <- gsub("MK", "Mound Key", inp.dxy.avg$Group )
group_ordered <- with(inp.dxy.avg,  reorder(Group,  Mean,  median))
inp.dxy.avg$Group <- factor(inp.dxy.avg$Group,
                            levels = levels(group_ordered))



plot.inp.dxy.avg <- ggplot(inp.dxy.avg, aes(x= Mean, y= Group)) + 
  geom_boxplot( fill = "#56B4E9", alpha = 0.5, outlier.shape=NA, size = 0.3) +
  geom_point( color = "#E69F00", alpha = 0.3, size = 2) +
  stat_summary(fun=mean, geom="point", shape=18, size=3, color="blue", fill="blue") +
  
#  ylab("Group")+
  xlab("Avg Dxy / Chromosome")+
  theme_classic() +
  theme(axis.title.y=element_blank())

################

inp.fst <-read.table("MK_Known_n65_fst.txt",sep="\t",header=T)
chrOrder <- sort(unique(inp.fst$chromosome))
inp.fst$chrOrder <- factor(inp.fst$chromosome,levels=chrOrder)
inp.fst$Group <- str_c(inp.fst$pop1, "_", inp.fst$pop2)

inp.fst.avg <- inp.fst %>%
  #  filter(.,c(pop1 == "Wild" | pop2 == "Wild")) %>%
  #  filter(.,pop1 %in% c("MoundKeyPop1", "MoundKeyPop2")) %>%
  group_by(pop1, pop2, chromosome, Group) %>%
  dplyr::summarize(Mean = mean(avg_wc_fst , na.rm=TRUE)) %>%
  as.data.frame()


inp.fst.avg$Group <- gsub("MK", "Mound Key", inp.fst.avg$Group )
group_ordered <- with(inp.fst.avg,  reorder(Group,  Mean,  median))
inp.fst.avg$Group <- factor(inp.fst.avg$Group,
                            levels = levels(group_ordered))
inp.fst.avg2 <- inp.fst.avg %>%
  group_by(Group) %>%
  dplyr::summarize(Mean = mean(Mean , na.rm=TRUE)) %>% 
  mutate(across(Mean, round, 2))

plot.inp.fst.avg <- ggplot(inp.fst.avg, aes(x= Mean, y= Group)) + 
  geom_boxplot( fill = "#56B4E9", alpha = 0.5, outlier.shape=NA, size = 0.3) +
  geom_point(color = "#E69F00", alpha = 0.3, size = 2) +
#  ylab("Group")+
  xlab("Avg Fst / Chromosome")+
  stat_summary(fun.y=mean, geom="point", shape=18, size=3, color="blue", fill="blue") +
#  geom_text(data = inp.fst.avg2, aes(label = Mean, y = Group) , nudge_x = 0.05, nudge_y = -0.15) +
  
  theme_classic()+
  theme(axis.title.y=element_blank())

plot.inp.fst.avg
################
################



finalplot <- ggdraw() +
  draw_plot(plot.inp.pi.avg, x = 0, y = 0.5, width = 0.5, height = 0.5) +
  draw_plot(plot.inp.dxy.avg, x = 0.5, y = 0.5, width = 0.5, height = 0.5) +
  
  draw_plot(LD_dec_plot , x = 0, y = 0, width = 0.5, height = 0.5) +
  draw_plot(plot.inp.fst.avg, x = 0.5, y = 0, width = 0.5, height = 0.5) +
  
  draw_plot_label(label = c("A", "B", "C", "D"), size = 15,
                  x = c(0, 0, 0.5, 0.5), y = c(1, 0.5, 1 , 0.5))


pdf("Fig2_MK_pi_dxy_fst_n65.pdf", width = 14, height = 10)
finalplot
dev.off()













#########################################################################
#########################################################################
#########################################################################

LD_dec <- read.table("LD_n65.txt", header = T)
LD_dec$Accession <- LD_dec$name_file
LD_dec$Accession<- gsub("MK.*","Mound Key (Down sampling with 10 replicates)",LD_dec$Accession)

head(LD_dec)
unique(LD_dec$Accession)

LD_dec$Mean_r.2 <- as.numeric(LD_dec$Mean_r.2)
LD_dec$Dist <- as.numeric(LD_dec$Dist)

LD_dec_plot <- ggplot(LD_dec, aes(x=Dist/1000, y=Mean_r.2, group=name_file)) +
  geom_line(aes(color=Accession), size = 1.2)+
#  geom_point(aes(color=name_file)) +
#  scale_x_continuous(limits=c(0, 500000), breaks = c(0, 100000, 200000, 300000, 400000, 500000)) +
  scale_y_continuous(limits=c(0, 1), breaks = seq(0, 1, 0.2)) +
  ylab(expression(r^{2})) +
  xlab("Distance (kb)") +
  theme_bw() +
  scale_color_manual(name = "Population/Group",
                     values=c("Mound Key (Down sampling with 10 replicates)"= "black",
                              "Wild" = "#0072B2",
                              "Landrace1" = "#E69F00",
                              "Landrace2" = "#CC79A7",
                              "Cultivar" = "#009E73"))  +
  theme(legend.position =  c(0.65, 0.8),
        legend.key = element_rect(fill = "white", colour = "grey30", linetype="dotted")) 

LD_dec_plot

####################################

pdf("Fig3_MK_LD_n65.pdf", width = 11, height = 8)
LD_dec_plot
dev.off()
