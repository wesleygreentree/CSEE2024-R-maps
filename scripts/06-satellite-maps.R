## Satellite imagery
# here we are using basemaps package
# another option is the OpenStreetMap package

library(basemaps)
library(tidyverse)
library(stars)
library(sf)

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

# will use Esri World imagery through the basemaps package
# can also get other types of basemaps, see here:
get_maptypes()


# can make quick maps with draw_ext()
drawn.extent <- draw_ext()
basemap_ggplot(ext = drawn.extent,
               map_service = "esri",
               map_type = "world_imagery")
# basemap_ggplot() will error if you did not draw an extent!

# can add more features to basemap_ggplot(), e.g.:
# basemap_ggplot(ext = drawn.extent,
#                map_service = "esri",
#                map_type = "world_imagery") +
#    ... add more ggplot calls here


# more formal method, through geom_stars
# define bounding box
bc.box <- st_bbox(c(xmin = -123.95, ymin = 48.1, xmax = -122.9, ymax = 48.7),
                        crs = st_crs(4326))

satellite <- basemap_stars(ext = bc.box,
                           map_service = "esri",
                           map_type = "world_imagery",
                           map_res = 1)
class(satellite) # stars: raster cubes 
st_crs(satellite) # 3857 (Web Mercator)
# Can transform to WGS84, but reduces quality

# convert from three band imagery to one RGB satellite image
satellite.rgb <- st_rgb(satellite)

plot(satellite) # see the three different bands

# transform to WGS84 (didn't here, to keep resolution)
#satellite.rgb <- st_transform(satellite.rgb, crs = st_crs(4326))

st_crs(satellite.rgb)

# load in rockfish data, convert to Web Mercator projection
rca <- read_sf("data-raw/rca-shapefile/rockfish_102001.shp")
st_crs(rca) # in EPSG 102001, Canada Albers Equal Area Conic
rca.wm <- st_transform(rca, crs = st_crs(3857))

# get only the RCAs in the satellite map bounding box
rca.wm <- st_crop(rca.wm, y = satellite.rgb) # warning is fine

ggplot() +
  geom_stars(data = satellite.rgb) +

  geom_sf(data = rca.wm, fill = "firebrick1", colour = "firebrick1",
          alpha = 0.4) +

  coord_sf(expand = FALSE) +
  theme_inset()
