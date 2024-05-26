# Animated maps

library(ggplot2)
library(gganimate)
library(basemaps)
library(sf)
library(stars)
library(rnaturalearth)
  
# simple animated map of humpback whale migrations from Antarctica
# to the equator
humpbacks <- readRDS("data/humpback-whales.RDS")

# get basemap from RNatural Earth, selecting continents
south.america.antarctica <- ne_countries(scale = "medium", 
                                         continent = c("north america",
                                                       "south america",
                                                       "antarctica"))

static <- ggplot() +
  geom_sf(data = south.america.antarctica) +
  
  geom_point(data = humpbacks,
             aes(x = longitude, y = latitude, colour = animal_id),
             size = 3) +
  geom_path(data = humpbacks,
            aes(x = longitude, y = latitude, colour = animal_id),
             linewidth = 1.5, alpha = 0.5) +
  scale_colour_manual(values = c("#f44336", "#2196f3", "#ffc007", "#9507FF")) +
  
  coord_sf(xlim = c(-100, -25), ylim = c(-80, 15),
           crs = st_crs(4326)) +
  theme_bw() +
  theme(legend.position = "none",
        panel.grid = element_blank())
static

dynamic <- static +
  transition_reveal(datetime) +
  labs(title = "Date: {lubridate::as_date(frame_along)}") +
  ease_aes("linear")

# save low resolution version (saves quickly)
anim_save("figures/whale-animation-low-res.gif", dynamic)

# oor save high resolution version (takes a long time)
anim_save("figures/whale-animation.gif", dynamic,
          height = 15, width = 12, units = "cm",
          res = 600, fps = 10, nframes = 150)
# if this doesn't run successful on your computer, decrease resolution,
# size and number of frames (animations are RAM intensive)