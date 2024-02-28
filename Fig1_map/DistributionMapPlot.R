setwd(getwd())

library(mapdata)
library(usmap)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(ggspatial)
library(maptools)
library(ggmap)
library(ggsn)
library(dplyr)
library(maps)
library(maptools)
library(ggplot2)
library(grid)
library(cowplot)

#Mound Key population GPS, due to data confidential, the GPS record is not included. 
gpsmk <-read.csv("CottonSamplingMap.csv")

#Given the size of Mound Key, a higher resolution map is required, and we applied Stadia Maps which requir an API (https://docs.stadiamaps.com/guides/migrating-from-stamen-map-tiles/).
register_stadiamaps("INSTER YOUR API KEY HERE", write = FALSE)

#Define boardr of Mound Key, and plot MK first
bc_bbox <- c(-81.870, 26.417 , -81.859, 26.428) #zoom16

MK_samplingplot <- get_stadiamap(bc_bbox, zoom = 17, maptype = "stamen_terrain", crop = FALSE) %>%
  ggmap() +
  geom_point(aes(x = long, y = lat, colour = Site, shape = Site), data = MK_accession, size = 4) +
  scale_color_manual(values=c("Site1"= "#0072B2",
                              "Site2" = "#E69F00",
                              "Site3" = "#CC79A7")) +
  xlab("Longitude") + ylab("Latitude") +
  scalebar( x.min = -81.873, x.max = -81.867, y.min = 26.418, y.max = 26.420,
           dist = 100, dist_unit = "m", st.size =3, height =0.07, st.dist = .12,
           transform = TRUE, model = "WGS84") +
  theme(#axis.title.x=element_blank(),
        #axis.title.y=element_blank(),
        legend.position = c(0.90, 0.5),
        legend.background = element_rect(fill= "transparent", size=.5, linetype="dotted"))


#Draw Florida from world map
world <- ne_countries(scale = "medium", type = "countries", returnclass = "sf")

florida <-  ggplot(data = world) +
  geom_sf(color = "black", fill = "grey70") +
  coord_sf(xlim = c(-85, -78), ylim = c(24, 32), expand = FALSE)  +
  scale_x_continuous(limits = c(-85, -78), breaks = seq(-85, -78, 3),labels = scales::label_number(accuracy = 0.01)) +
  scale_y_continuous(limits = c(24, 32), breaks = seq(24, 32, 3), labels = scales::label_number(accuracy = 0.01)) +
  
  geom_point(data = gpsmk, mapping = aes(x = long, y = lat, color = Population),  size =3, show.legend = F) +
  scale_color_manual(values=c("Mound Key"= "black")) +
  annotate(geom = "text", x = -81, y = 27, label = "Mound Key", fontface = "bold", color = "black", size = 3) +
#  theme_transparent()
  theme(panel.background = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        panel.border = element_rect(colour = "black", fill=NA, linewidth=0.1))

#Combine MK and Florida together 

florida_grob <- ggplotGrob(florida)
plotfinal <- ggdraw(MK_samplingplot) + draw_grob(florida_grob, x = 0.8, y = 0.05, width = 0.2, height = 0.3)

pdf("Fig1_Cotton_WorldDistribution_MK.pdf", width = 7, height = 7)
plotfinal
dev.off()


