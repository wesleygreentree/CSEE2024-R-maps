## Study area map

# this script is broken into three pieces
# 1. Simple study area map
# 2. Adding bathymetry and topography
# 3. Add rockfish data (learn how to add polygons and points)
# 4. Making study area maps in another projection, and how to crop maps
# easily when the projection is in metres

# load packages
library(sf)
library(ggplot2)
library(ggspatial)
library(patchwork)

# define custom plot themes 
# kudos to Dominique Maucieri, PhD student at UVic 
# https://dominiquemaucieri.com/stats_code.html

theme_map <- function () {
  theme_bw() +
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          axis.title = element_blank(),
          axis.text = element_text(size = 11))
}

theme_inset <- function () {
  theme_bw() +
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          axis.title = element_blank(), 
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          legend.position = "none",
          plot.background = element_blank(),
          plot.margin = unit(c(0, 0, 0, 0), "cm"),
          axis.ticks.length.x = unit(0,'pt'))
} 

# read in data
bc.coast <- read_sf("data/bc-coast.shp")
st_crs(bc.coast) # WGS 1984 (EPSG 4326)


## 1. Simple study area map, including inset
study.area <- ggplot() +
  geom_sf(data = bc.coast) +
  
  annotate(geom = "rect",
           xmin = -123.4, xmax = -123.1, ymin = 48.4, ymax = 48.75,
           fill = "transparent", colour = "black",
           linetype = "dashed") +
  
  # label water bodies: 
  # \n indicates a line break, which we reduce the size of with lineheight = 0
  annotate(geom = "text",
           x = -123.5, y = 49.2,
           label = "Strait of\nGeorgia",
           fontface = "italic",
           size = 4.2, lineheight = 0.75, colour = "steelblue") +
  annotate(geom = "text",
           x = -124.05, y = 48.32,
           label = "Strait of Juan de Fuca",
           fontface = "italic",
           size = 4.2, colour = "steelblue") +
  annotate(geom = "text",
           x = -123.245, y = 48.52,
           label = "Haro \n Strait",
           fontface = "italic",
           size = 4.2, lineheight = 0.75, colour = "steelblue") +
  
  # land labels
  annotate(geom = "text",
           x = -124.15, y = 48.8, 
           label = "Vancouver\nIsland",
           size = 4.2, lineheight = 0.75, colour = "black") +
  annotate(geom = "text",
           x = -123.46, y = 49, 
           label = "Gulf\n     Islands",
           size = 4.2, lineheight = 0.75, colour = "black") +
  
  # add scale bar and north arrow
  annotation_scale(width_hint = 0.35, style = "bar") + 
  # width_hint is how you change the distance represented by the scalebar
  annotation_north_arrow(location = "tr", 
                         height = unit(0.9, "cm"), width = unit(0.6, "cm"),
                         which_north = "true") +
  
  coord_sf(xlim = c(-124.5, -122.5), ylim = c(48, 49.5)) +
  scale_x_continuous(breaks = c(-122.5, -123, -123.5, -124, -124.5)) +
  scale_y_continuous(breaks = c(48, 48.5, 49, 49.5)) +
  
  theme_map()
study.area

# inset
inset <- ggplot() +
  geom_sf(data = bc.coast, linewidth = 0.04) + # decrease linewidth from default
  
  annotate(geom = "rect", 
           xmin = -124.5, xmax = -122.5, ymin = 48, ymax = 49.5,
           fill = "transparent", colour = "black") +
  
  # label waterbodies
  annotate(geom = "text",
           x = -130, y = 47,
           label = "Pacific Ocean",
           fontface = "italic",
           size = 4.2, colour = "steelblue") +
  
  # label land
  annotate(geom = "text",
           x = -124, y = 53,
           label = "British\nColumbia",
           size = 4.2, lineheight = 0.75, colour = "black") +
  annotate(geom = "text",
           x = -122, y = 46,
           label = "USA",
           size = 4.2, colour = "black") +
  
  coord_sf(xlim = c(-134, -120), ylim = c(45, 55)) +
  theme_inset()
inset

# add inset to the main study area map
study.area + inset_element(inset,
                           left = -0.007, bottom = 0.6, right = 0.4, top = 1.008,
                           align_to = "panel")
# when left = 0, top = 1: there is a slight gap between the left and top
# edge of the inset and the larger map behind it. Setting left = -0.01 and
# top = 1.01 aligns edges nicely.

# leaving it as left = 0 and top = 1 is perfectly acceptable, as well! 

ggsave("figures/study-area-with-inset.PNG", 
       width = 17, height = 17, units = "cm",
       background = "white", dpi = 300)


## 2. Add bathymetry and topography 
# see scripts/04-bathymetry.R and scripts/05-topography.R for full details
# and explanations on what is happening

library(tidyterra)
library(terra)

# read in digital elevation model
gebco <- readRDS("data/gebco.RDS")

# get bathymetry layer
gebco.ocean <- mask(gebco, mask = bc.coast, inverse = TRUE)

# calculate hillshading layer for topography
gebco.clipped <- crop(gebco, bc.coast, mask = TRUE)
gebco.slope <- terra::terrain(gebco.clipped, v = "slope", unit = "radians") 
gebco.aspect <- terra::terrain(gebco.clipped, v = "aspect", unit = "radians")
gebco.hillshade <- shade(slope = gebco.slope, aspect = gebco.aspect,
                         angle = 45, direction = 315)

ggplot() +
  geom_spatraster(data = gebco.hillshade,
                  maxcell = 5e+15, alpha = 1,
                  show.legend = FALSE) + # 0.7 or 0.45?
  scale_fill_distiller(palette = "Greys", na.value = "transparent") +
  
  # add bathymetry, and plot land overtop
  ggnewscale::new_scale_fill() +
  
  geom_spatraster(data = gebco.ocean,
                  maxcell = 5e+15) +
  scale_fill_fermenter(palette = "Blues",
                       breaks = c(-50, -100, -200, -300, -400),
                       labels = c(">400", "300", "200", "100", "50"),
                       na.value = "transparent") +
  labs(fill = "Depth (m)") + # assigns legend title
  
  # add land boundary
  geom_sf(data = bc.coast, fill = "transparent", colour = "black") +
  
  # add scale bar and north arrow
  annotation_scale(width_hint = 0.35, style = "bar") + 
  annotation_north_arrow(location = "tr", 
                         height = unit(0.9, "cm"), width = unit(0.6, "cm"),
                         which_north = "true") +
  
  coord_sf(xlim = c(-124.5, -122.5), ylim = c(48, 49.5)) +
  scale_x_continuous(breaks = c(-122.5, -123, -123.5, -124, -124.5)) +
  scale_y_continuous(breaks = c(48, 48.5, 49, 49.5)) +
  theme_map()

## 3. add rockfish conservation areas and use BC Albers
rca <- read_sf("data-raw/rca-shapefile/rockfish_102001.shp")
st_crs(rca) # in EPSG 102001, Canada Albers Equal Area Conic

# transform to WGS1984 (same as the bc.coast basemap)
rca.wgs <- st_transform(rca, crs = st_crs(4326))

# load in rockfish observations from iNaturalist
iNaturalist.rockfish <- read.csv("data/iNaturalist-rockfish.csv")

rockfish <- ggplot() +
  geom_sf(data = rca.wgs, 
          fill = "firebrick1", colour = "firebrick1", alpha = 0.4) +
  
  # some observations were on land, so plot iNaturalist observations behind 
  # land (likely GPS or data upload errors)
  geom_point(data = iNaturalist.rockfish,
             aes(x = longitude, y = latitude),
             colour = "steelblue3", size = 2, alpha = 0.7) +

  geom_sf(data = bc.coast) +
  
  coord_sf(xlim = c(-123.9, -122.8), ylim = c(48.0, 48.8)) +
  theme_map()
rockfish

inset <- ggplot() +
  geom_sf(data = bc.coast, linewidth = 0.04) + # decrease linewidth from default
  
  annotate(geom = "rect", 
           xmin = -123.9, xmax = -122.8, ymin = 48, ymax = 48.8,
           fill = "transparent", colour = "black") +
  
  coord_sf(xlim = c(-134, -120), ylim = c(45, 55)) +
  theme_inset()
inset

# add labels and an inset map
rockfish +
  annotation_scale(width_hint = 0.25) +
  annotation_north_arrow(location = "tr", 
                         height = unit(0.9, "cm"), width = unit(0.6, "cm"),
                         which_north = "true") +
  
  # same labels and inset code as before
  annotate(geom = "text",
           x = -123.48, y = 48.25,
           label = "Strait of Juan de Fuca",
           fontface = "italic",
           size = 4, colour = "steelblue") +
  annotate(geom = "text",
           x = -123.365, y = 48.46,
           label = "Victoria", 
           size = 4, colour = "black") +
  
  # add legend for RCAs (manually since only one level)
  annotate(geom = "rect",
           xmin = -123.9, xmax = -123.8, ymin = 48.01, ymax = 48.03,
           colour = "firebrick1", fill = "firebrick1", alpha = 0.4) +
  annotate(geom = "text",
           x = -123.55, y = 48.023,
           label = "Rockfish conservation areas", 
           size = 4, colour = "black") +
  
  inset_element(inset,
                left = -0.01, bottom = 0.7, right = 0.3, top = 1,
                align_to = "panel")

# alternative: add depth contours
ggplot() +
  # depth contours
  geom_spatraster_contour(data = gebco.ocean, maxcell = 5e+15,
                          breaks = c(-50)) +
  
  # the rest is the same as previously
  geom_sf(data = rca.wgs, 
          fill = "firebrick1", colour = "firebrick1", alpha = 0.4) +
  
  # some observations were on land, so plot iNaturalist observations behind 
  # land (likely GPS or data upload errors)
  geom_point(data = iNaturalist.rockfish,
             aes(x = longitude, y = latitude),
             colour = "steelblue3", size = 2, alpha = 0.7) +
  
  geom_sf(data = bc.coast) +
  
  coord_sf(xlim = c(-123.9, -122.8), ylim = c(48.0, 48.8)) +
  theme_map() +

  # same labels and inset code as before
  annotate(geom = "text",
           x = -123.48, y = 48.25,
           label = "Strait of Juan de Fuca",
           fontface = "italic",
           size = 4, colour = "steelblue") +
  annotate(geom = "text",
           x = -123.365, y = 48.46,
           label = "Victoria", 
           size = 4, colour = "black") +
  
  # add legend for RCAs (manually since only one level)
  annotate(geom = "rect",
           xmin = -123.9, xmax = -123.8, ymin = 48.01, ymax = 48.03,
           colour = "firebrick1", fill = "firebrick1", alpha = 0.4) +
  annotate(geom = "text",
           x = -123.55, y = 48.023,
           label = "Rockfish conservation areas", 
           size = 4, colour = "black") +
  
  inset_element(inset,
                left = -0.01, bottom = 0.7, right = 0.3, top = 1,
                align_to = "panel")
# the gaps in contours may be because GEBCO file is relatively low-resolution
# (e.g., very sharp drop offs in Saanich Inlet) 
# using the full gebco file (not gebco.ocean) can also help


## 4 study area maps in other projections

bc.coast.albers <- st_transform(bc.coast, crs = st_crs(4326))
albers.graticules <- st_graticule(bc.coast.albers)

# labels in metres
ggplot() +
  geom_sf(data = bc.coast.albers) +
  geom_sf(data = albers.graticules) + 
  coord_sf(crs = st_crs(3005), datum = st_crs(3005)) +
  theme_map()

# if we want labels in degrees
ggplot() +
  geom_sf(data = bc.coast) +
  geom_sf(data = albers.graticules) + 
  coord_sf(crs = st_crs(3005), datum = st_crs(4326))

# we can't crop this the same way, because albers doesn't use degrees
# can crop using the raw metres, or in the following way
long.lat.bbox <- st_sfc(
  st_polygon(list(cbind(
    c(-123.9, -122.8, -122.8, -123.9, -123.9), # x coordinates: xmin, xmax, xmax, xmin, xmin
    c(48, 48, 48.8, 48.8, 48) # y coordinates: ymin, ymin, ymax, ymax, ymin
  ))),
  crs = st_crs(4326))

albers.bbox <- st_transform(long.lat.bbox, crs = st_crs(3005))
albers.bbox2 <- st_bbox(albers.bbox)


ggplot() +
  ggtitle("WGS 1984") +
  geom_sf(data = bc.coast) +
  annotation_north_arrow(location = "tr", 
                         height = unit(0.9, "cm"), width = unit(0.6, "cm"),
                         which_north = "true") +
  coord_sf(xlim = c(-123.9, -122.8), ylim = c(48, 48.8)) +
  theme_bw()

ggplot() +
  ggtitle("BC Albers") +
  geom_sf(data = bc.coast.albers) +
  annotation_north_arrow(location = "tr", 
                         height = unit(0.9, "cm"), width = unit(0.6, "cm"),
                         which_north = "grid") +
  # if you set which_north = "grid", you can see the north arrow changes
  # direction slightly
  
  coord_sf(crs = st_crs(3005), 
           xlim = c(albers.bbox2["xmin"], albers.bbox2["xmax"]),
           ylim = c(albers.bbox2["ymin"], albers.bbox2["ymax"])) +
  theme_bw()

# thanks to https://github.com/tidyverse/ggplot2/issues/2090
