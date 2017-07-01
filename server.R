library(leaflet)
library(RColorBrewer)
library(scales)
library(plotly)
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
  
  # create bubble visualisation
  output$bubbles <- renderPlotly ({
    
    colors <- c('#4AC6B7', '#1972A4', '#965F8A', '#FF7070', '#C61951')
    
    plot_ly(allCities, x = ~gdp, y = ~pollution, text = ~city, type = 'scatter', color = ~cluster, colors = colors,
            mode = 'markers', marker = list(size = 5, opacity = 0.5)) %>%
      layout(title = 'Gender Gap in Earnings per University',
             xaxis = list(showgrid = FALSE),
             yaxis = list(showgrid = FALSE))

    })
}
