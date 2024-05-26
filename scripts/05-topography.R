## Hillshading to illustrate topography

# for more inspiration: 
# https://dominicroye.github.io/en/2022/hillshade-effects/

library(terra)
library(tidyterra)
library(sf)
library(ggplot2)

bc.coast <- read_sf("data/bc-coast.shp")
st_crs(bc.coast)

# read in digital elevation model, with terra::rast()
gebco <- rast("data-raw/gebco-dem/gebco_2023_n55.0_s44.0_w-135.0_e-120.0.asc")

terra::crs(gebco) # WGS84, but EPSG 6326 not 4326
st_crs(gebco)

# look at digital elevation model
gebco.cropped <- crop(gebco, ext(c(-130, -120, 46.9, 52)))
range(gebco.cropped)
limit <- max(abs(3810)) * c(-1, 1) 
# this centres the colour scale on zero, by setting limits
# around the maximum absolute value

ggplot() +
  geom_spatraster(data = gebco.cropped) +
  geom_sf(data = bc.coast, fill = "transparent", colour = "black") +
  scale_fill_distiller(palette = "BrBG", limit = limit, type = "div") +
  coord_sf(xlim = c(-130, -120), ylim = c(46.9, 52),
           expand = FALSE, crs = st_crs(4326)) +
  theme_bw()

# clip the digital elevation model to be only on land 
# note that hillshading can also be used for the ocean!!
gebco.clipped <- crop(gebco, bc.coast, mask = TRUE)
plot(gebco.clipped)
# another option here would be to use terra::clamp(lower = 0),
# but it doesn't work as well


# calculate hillshading layer to illustrate topography
gebco.slope <- terra::terrain(gebco.clipped, v = "slope", unit = "radians") 
ggplot() +
  geom_spatraster(data = gebco.slope) +
  geom_sf(data = bc.coast, fill = "transparent", colour = "black") +
  coord_sf(xlim = c(-130, -120), ylim = c(47, 52), expand = FALSE)

gebco.aspect <- terra::terrain(gebco.clipped, v = "aspect", unit = "radians")
ggplot() +
  geom_spatraster(data = gebco.aspect) +
  geom_sf(data = bc.coast, fill = "transparent", colour = "black") +
  coord_sf(xlim = c(-130, -120), ylim = c(47, 52), expand = FALSE)

gebco.hillshade <- shade(slope = gebco.slope, aspect = gebco.aspect,
                         angle = 45, direction = 315)
ggplot() +
  geom_spatraster(data = gebco.hillshade,
                  maxcell = 5e+15, alpha = 1) + 
  geom_sf(data = bc.coast, linewidth = 0.3, fill = "transparent") +
  scale_fill_distiller(palette = "Greys", na.value = "transparent") +
  coord_sf(xlim = c(-124.5, -122.5), ylim = c(48, 49.5))

ggplot() +
  geom_spatraster(data = gebco.hillshade, maxcell = 5e+15) +
  geom_sf(data = bc.coast, fill = "transparent", colour = "black") +
  coord_sf(xlim = c(-130, -120), ylim = c(47, 52), expand = FALSE)

# plot hillshading and land boundaries (bc.coast)
ggplot() +
  geom_sf(data = bc.coast, colour = "black") +
  geom_spatraster(data = gebco.hillshade,
                  maxcell = 5e+15, alpha = 0.7) + # set maxcell high, so that the raster is kept as original
  coord_sf(xlim = c(-130, -120), ylim = c(46.9, 52), expand = FALSE, crs = st_crs(4326)) +
  scale_fill_distiller(palette = "Greys", na.value = "transparent") +
  theme_bw() +
  theme(legend.position = "none",
        axis.text = element_text(size = 12))