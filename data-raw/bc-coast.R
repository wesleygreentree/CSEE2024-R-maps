# Make bc-coast.shp for use in CSEE workshop
# Provides a small shapefile so that participants don't need to download large file

# Derived from North America shapefile, US State Dept Office of the Geographer
# Downloaded from: # https://searchworks.stanford.edu/view/cq068zf3261

# read packages
library(sf) # s2 geometry on
library(ggplot2)

# read shapefile
us.gov.north.america <- read_sf("data-raw/us-gov-north-america/data_EPSG_4326/North_America.shp")
st_crs(us.gov.north.america) # EPSG 4326

table(st_is_valid(us.gov.north.america)) # all true - valid shapefile

ggplot() +
  geom_sf(data = us.gov.north.america) +
  coord_sf(crs = 4326,
           xlim = c(-145, -110), ylim = c(44, 60),
           expand = FALSE) +
  theme_bw()

# crop to BC coast and surrounding areas
bc.coast.box <- st_bbox(c(xmin = -145, ymin = 40, xmax = -110, ymax = 65),
                        crs = st_crs(4326))
st_crs(bc.coast.box)

bc.coast <- st_crop(us.gov.north.america, bc.coast.box)

# ggplot() +
#   geom_sf(data = bc.coast) +
#   coord_sf(crs = 4326, datum = 4326, expand = FALSE) +
#   theme_bw()
# 
# ggplot() +
#   ggtitle("North America") +
#   geom_sf(data = us.gov.north.america) +
#   coord_sf(crs = 4326, xlim = c(-125, -121), ylim = c(47, 50),
#            expand = FALSE)
# 
# ggplot() +
#   ggtitle("BC coast") +
#   geom_sf(data = bc.coast) +
#   coord_sf(crs = 4326, xlim = c(-125, -121), ylim = c(47, 50),
#            expand = FALSE)

#st_write(bc.coast, "data/bc-coast.shp")
#saveRDS(bc.coast, "data/bc-coast.RDS")

# check <- read_sf("data/bc-coast.shp")
# ggplot() +
#   ggtitle("Check") +
#   geom_sf(data = check) +
#   coord_sf(crs = 4326, xlim = c(-125, -121), ylim = c(47, 50),
#            expand = FALSE)

# # compare if s2 geometry influences st_crop
# sf_use_s2(TRUE)
# bc.coast.s2true <- st_crop(us.gov.north.america,
#                     bc.coast.box)
# sf_use_s2(FALSE)
# bc.coast.s2false <- st_crop(us.gov.north.america,
#                             bc.coast.box)
# 
# s2.true <- ggplot() +
#   ggtitle("s2 TRUE") +
#   geom_sf(data = bc.coast.s2true) +
#   coord_sf(xlim = c(-135, -120), ylim = c(45, 55)) +
#   theme_bw()
# 
# s2.false <- ggplot() +
#   ggtitle("s2 FALSE") +
#   geom_sf(data = bc.coast.s2false) +
#   coord_sf(xlim = c(-135, -120), ylim = c(45, 55)) +
#   theme_bw()
# ggpubr::ggarrange(s2.true, s2.false)
# 
# ggplot() +
#   geom_sf(data = bc.coast.s2true, fill = "red", alpha = 0.5) +
#   geom_sf(data = bc.coast.s2false, fill = "blue", alpha = 0.5) +
#   coord_sf(xlim = c(-123.5, -123), ylim = c(48.5, 48.7))
