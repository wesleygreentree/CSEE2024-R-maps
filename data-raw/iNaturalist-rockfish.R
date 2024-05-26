## iNaturalist rockfish data

library(readr)

iNaturalist.rockfish <- read.csv("data-raw/iNaturalist/iNaturalist-rockfish.csv")

iNaturalist.rockfish <- select(iNaturalist.rockfish, id, observed_on,
                               quality_grade, longitude, latitude, common_name)
write_csv(iNaturalist.rockfish, "data/iNaturalist-rockfish.csv")
