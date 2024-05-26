
library(ggplot2)
library(sf)
library(rnaturalearth)

# R Natural Earth
natural.earth10 <- rnaturalearth::ne_countries(scale = "large",
                                               continent = "north america",
                                               returnclass = "sf")

st_crs(natural.earth10) # WGS 84, epsg 4326

# highest resolution in RNaturalEarth (1:10M, 1 m = 10,000 km)
ggplot() +
  ggtitle("R Natural Earth, 1:10M") +
  geom_sf(data = natural.earth10) +
  theme_bw() +
  coord_sf(xlim = c(-129, -121.5), ylim = c(47, 51))
ggsave("figures/naturalearth-10.PNG", width = 12, height = 12, units = "cm")

ggplot() +
  ggtitle("Bamfield") +
  geom_sf(data = natural.earth10) +
  theme_bw() +
  coord_sf(xlim = c(-125.65, -124.9), ylim = c(48.65, 49.12))

# medium resolution (1:50 M)
north.america50 <- rnaturalearth::ne_countries(scale = 50, continent = "north america",
                                                returnclass = "sf")

ggplot() +
  ggtitle("R Natural Earth, 1:50M") +
  geom_sf(data = north.america50) +
  theme_bw() +
  coord_sf(xlim = c(-129, -121.5), ylim = c(47, 51))
ggsave("figures/naturalearth50.PNG", width = 12, height = 12, units = "cm")


## Provided shapefile for BC coast (source: US Dept of State)
# this is the shapefile we will use throughout the workshop,
# please use this for your own work!

bc.coast <- read_sf("data/bc-coast.shp")
st_crs(bc.coast)

ggplot() +
  ggtitle("BC coast shapefile") +
  geom_sf(data = bc.coast) +
  theme_bw() +
  coord_sf(xlim = c(-129, -121.5), ylim = c(47, 51))
ggsave("figures/bc-coast-shapefile.PNG", width = 12, height = 12, units = "cm")

ggplot() +
  ggtitle("Bamfield") +
  geom_sf(data = bc.coast) + 
  theme_bw() +
  coord_sf(xlim = c(-125.65, -124.9), ylim = c(48.65, 49.12))
ggsave("figures/bc-coast-vancouver.PNG", width = 12, height = 12, units = "cm")

# Very high resolution shapefile for BC from Hakai Institue
# download from https://github.com/HakaiInstitute/hakai_guide_to_r/tree/master/data
hakai <- read_sf("data-raw/hakai-shapefile/COAST_TEST2.shp")
class(hakai)
st_crs(hakai)

ggplot() +
  ggtitle("Hakai, higher resolution") +
  geom_sf(data = hakai) +
  theme_bw() +
  coord_sf(xlim = c(-129, -121.5), ylim = c(47, 51))
ggsave("figures/hakai-bc.PNG", width = 12, height = 12, units = "cm")

# Bamfield
ggplot() +
  geom_sf(data = hakai) + 
  theme_bw() +
  annotate(geom = "rect",
           xmin = -125.25, xmax = -125.05, ymin = 48.8, ymax = 48.95,
           fill = NA, colour = "black") +
  
  coord_sf(xlim = c(-125.65, -124.9), ylim = c(48.65, 49.12))

# zoom in futher
ggplot() +
  geom_sf(data = hakai) + 
  theme_bw() +
  coord_sf(xlim = c(-125.25, -125.05), ylim = c(48.8, 48.95))



## What about a satellite map?

# get Bamfield satellite map with basemaps package
library(basemaps)

# Barkley sound
bam.box <- st_bbox(c(xmin = -125.65, ymin = 48.65, xmax = -124.9, ymax = 49.12),
                  crs = st_crs(4326))

basemap_ggplot(ext = bam.box, 
               map_service = "esri", map_type = "world_imagery", res = 1,
               maxpixels = 5e+15) +
  theme_void()

# zoom in on BMSC
bam.box2 <- st_bbox(c(xmin = -125.2, ymin = 48.82, xmax = -125.1, ymax = 48.86),
                   crs = st_crs(4326))
basemap_ggplot(ext = bam.box2, 
               map_service = "esri", map_type = "world_imagery", res = 1,
               maxpixels = 5e+15) +
  theme_void()
