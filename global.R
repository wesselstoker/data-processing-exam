library(dplyr)

# load and prepare the geolocations
allLocations <- read.csv('data/simplemaps-worldcities-basic.csv')
allLocations <- select(allLocations, city, latitude=lat, longitude=lng)
allLocations$city <- tolower(allLocations$city)

# load and prepare the city pollution data
allCities <- read.csv('data/WHO_AAP_database_May2016_v3web.csv')
allCities <- select(allCities, country=Country, city=City.Town, pollution=Annual.mean..ug.m3)
allCities$city <- tolower(allCities$city)
allCities$pollution <- floor(allCities$pollution)
allCities <- arrange(allCities, desc(pollution))
allCities['id'] <- seq.int(nrow(allCities))

# find the highest Annual mean, ug/m3 so we use 100% datapoint
maxPollution = slice(arrange(allCities, desc(pollution)), 1)$pollution

# calculate the relative size of bubbles compared to the highest a amount of Annual mean, ug/m3
allCities["radius"] <- (allCities$pollution / (maxPollution / 80)) + 20
allCities["opacity"] <- (allCities$radius / 100) * 0.8

# boost the size of the bubbles to make sure every bubble is visible
allCities$radius <- allCities$radius * 1000

# combine the cities with the geolocations
allCities <- inner_join(allCities, allLocations, city=city)