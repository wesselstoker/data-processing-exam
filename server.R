library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

function(input, output, session) {

  # create the world map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = 'http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = 8.61, lat = 49.89, zoom = 3) # focus on europe
  })

  # A reactive expression that returns the set of cities that are in bounds right now
  citiesInBounds <- reactive({
    if (is.null(input$map_bounds)) return(allCities[FALSE,])
    
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)

    inBounds <- subset(allCities, latitude >= latRng[1] & latitude <= latRng[2] & longitude >= lngRng[1] & longitude <= lngRng[2])
    
    # reformat the collumn names
    select(inBounds, "Global ranking"=id, City=city, Country=country, "Annual mean, ug/m3"=pollution)
  })
  
  # add the circles the world map
  leafletProxy("map", data=allCities) %>%
    clearShapes() %>%
    addCircles(~longitude, ~latitude, radius=~radius, layerId=~id, stroke=FALSE, fillOpacity =~opacity, fillColor='#ff0000')
  
  # add the cities that are in bound to the table
  output$table = renderDataTable({
    citiesInBounds()
  })

}
