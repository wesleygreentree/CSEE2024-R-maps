# Clean humpback whale data for workshop

# Source:
# Weinstein et al. 2018. Capturing foraging and resting behavior using nested 
# multivariate Markov models in an air-breathing marine vertebrate. Movement Ecology

# Modest et al. 2021. First description of migratory behavior of humpback whales from 
# an Antarctic feeding ground to a tropical calving ground. Animal Biotelemetry

# Downloaded from: https://github.com/bw4sz/WhalePhys/
# https://bw4sz.github.io/WhalePhys/


library(tidyverse)

humpbacks <- read.csv("data-raw/humpback-whales/Humpback Whales Megaptera novaeangliae West Antarctic Peninsula-3343066988628153526.csv")

# standardize datetime with lubridate
humpbacks$datetime <- as_datetime(humpbacks$timestamp) 
names(humpbacks)

# select variables of interest and rename
humpbacks <- select(humpbacks, event.id, individual.local.identifier, datetime,
                               location.long, location.lat, algorithm.marked.outlier)
names(humpbacks) <- c("event_id", "animal_id", "datetime", "longitude",
                      "latitude", "outlier")
humpbacks$animal_id <- as.factor(humpbacks$animal_id)

# subset to 4 from 2013
humpbacks <- subset(humpbacks, animal_id %in% c("121207", "121210", "123224", "123232"))
range(humpbacks$datetime)

# remove outliers (likely satellite location errors), removes 464 locations
table(humpbacks$outlier)
sort(unique(humpbacks$outlier))
humpbacks <- subset(humpbacks, outlier == "" & longitude >-100)

# look at data
ggplot() +
  geom_point(data = humpbacks,
             aes(x = longitude, y = latitude, colour = animal_id))

# save as csv
#write_csv(humpbacks, "data/humpback-whales.csv", na = "")
#saveRDS(humpbacks, "data/humpback-whales.RDS")
