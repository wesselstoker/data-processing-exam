library(dplyr)

# load the geolocations dataset
allLocations <- read.csv('data/simplemaps-worldcities-basic.csv')
allLocations <- select(allLocations, city, latitude=lat, longitude=lng)

# normalize the geo locations
allLocations$city <- tolower(allLocations$city)

# load the GDP datatset
allGDPCountries <- read.csv('data/API_NY.GDP.PCAP.CD_DS2_en_csv_v2.csv')
allGDPCountries <- select(allGDPCountries, country_iso3=Country.Code, gdp=X2016)

# load the pollution dataset
allCities <- read.csv('data/WHO_AAP_database_May2016_v3web.csv')

# normalize the pollution dataset
allCities <- select(allCities, country=Country, city=City.Town, pollution=Annual.mean..ug.m3)
allCities$city <- tolower(allCities$city)
allCities$pollution <- floor(allCities$pollution)

# join the pollution dataset with the geolocations dataset
allCities <- inner_join(allCities, allLocations, city=city)

# join the pollution dataset with the GDP dataset
allCities <- inner_join(allCities, allGDPCountries, country_iso3=country_iso3)

# sort from highest to lowest
allCities <- arrange(allCities, desc(pollution))

# leaflet expects that every row has a id
allCities['id'] <- seq.int(nrow(allCities))

# get the maximium pollution number so we can use it as a normalization point
maxPollution = slice(arrange(allCities, desc(pollution)), 1)$pollution

# use a logarithmic function to determine the size of circles
allCities["radius"] <- (log(allCities$pollution) ^ 3) * 500

# bring the pollution numbers between 0 and 100 so we can set a opacity
allCities["opacity"] <- (allCities$pollution / (maxPollution / 100)) + 0
allCities$opacity <- ((allCities$opacity / 100) * 0.6) + 0.2

# cluster by city pollution and the country GDP
clusteringData <- select(allCities, pollution, gdp)

# create 5 different clusters with a reproducibility of 20
set.seed(100)
clustering <- kmeans(clusteringData, 5, nstart=100)

# combine the clustering results with the original data
allCities['cluster'] <- clustering$cluster




