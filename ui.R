library(leaflet)

basicPage(
  tags$head(
  includeCSS("styles.css")
  ),

  # render the world map
  leafletOutput("map", width="100%", height="100%"),

  # render sidebar with the dataTable
  div(class="sidebar",
    dataTableOutput('table')
  )
)