
# There is a known issue with R 4.4 and the RStudio viewer,
# which is used by leaflet
# See this Github issue on the leaflet Github:
# https://github.com/rstudio/rstudio/issues/14603
# This issue is still be addressed

# the code below was written in R 4.3.1


library(leaflet)
library(sf)

rockfish <- read.csv("data/iNaturalist-rockfish.csv")

# make a map to start
# |> is the baseR equivalent of the pipe ( %>% )

leaflet() |>
  setView(lng = -123, lat = 48.4, zoom = 9) |>
  addProviderTiles(providers$Esri.WorldImagery) |>
  addCircles(data = rockfish, 
             lng = rockfish$longitude, lat = rockfish$latitude,
             color = "red")
