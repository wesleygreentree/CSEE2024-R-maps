# Plot bathymetry rasters

library(terra)
library(tidyterra)
library(sf)
library(ggplot2)
library(ggnewscale)

bc.coast <- read_sf("data/bc-coast.shp")
st_crs(bc.coast)

# read in digital elevation model, with terra::rast()
#gebco <- rast("data-raw/gebco-dem/gebco_2023_n55.0_s44.0_w-135.0_e-120.0.asc")
# the original file was large (~50 MB), so it's not shared in the GitHub
# repository. 
# Instead, we have a smaller version (~5MB) saved as an R Data Storage (.RDS)
gebco <- readRDS("data/gebco.RDS")
gebco

terra::crs(gebco) # WGS84, but EPSG 6326 not 4326
st_bbox(gebco)

# look at digital elevation model
gebco.ocean <- mask(gebco, mask = bc.coast, inverse = TRUE)
plot(gebco.ocean)

# plot out bathymetry
ggplot() +
  geom_spatraster(data = gebco.ocean, maxcell = 5e+15) +
  scale_fill_fermenter(palette = "Blues",
                       breaks = c(-50, -100, -200, -300, -400),
                       labels = c("50", "100", "200", "300", "400"),
                       na.value = "transparent") +
  geom_sf(data = bc.coast, colour = "black") +

  coord_sf(xlim = c(-124.5, -122.5), ylim = c(48, 49.5),
           expand = FALSE, crs = st_crs(4326)) +
  theme_bw() +
  labs(fill = "Depth")
 
# plot depth contours # should bc.coast be on top and just highly transparent
ggplot() +
  geom_spatraster_contour(data = gebco.ocean, maxcell = 5e+15) +
  geom_sf(data = bc.coast, fill = "grey70", colour = "black") +
  coord_sf(xlim = c(-130, -120), ylim = c(46.9, 52),
           expand = FALSE, crs = st_crs(4326)) +
  theme_bw()

# 200, 500 m contours - remember that depth is negative
ggplot() +
  geom_spatraster_contour(data = gebco.ocean, maxcell = 5e+15,
                          breaks = c(-200, -500)) +
  geom_sf(data = bc.coast, fill = "grey70", colour = "black") +
  coord_sf(xlim = c(-130, -120), ylim = c(46.9, 52),
           expand = FALSE, crs = st_crs(4326)) +
  theme_bw() 
