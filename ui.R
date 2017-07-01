library(leaflet)
library(plotly)

navbarPage("", id="nav",
  tabPanel("Interactive world map",
    tags$head(
      includeCSS("styles.css")
    ),
    # render the world map
    leafletOutput("map", width="100%", height="100%"),
    
    # render sidebar with the dataTable
    div(class="sidebar",
      dataTableOutput('table')
    )
  ),
  tabPanel("In-depth Clustering",
    tags$head(
      includeCSS("styles.css")
    ),
    # render bubble graph
    plotlyOutput("bubbles")        
  )
)
                    
                    