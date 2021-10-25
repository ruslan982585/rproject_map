#Web app
library(shiny)
library(shinydashboard)
#Map
library(leaflet)
library(leaflet.extras)
library(sp)

ui <- dashboardPage(
  dashboardHeader(title = "Project Geo"),
  dashboardSidebar(
    sidebarMenu(
      menuItem(
        "Maps",
        tabName = "maps",
        icon = icon("globe"),
        #3 demo maps
        menuSubItem("Earthquake OSM", tabName = "m_osm", icon = icon("map")),
        menuSubItem("Earthquake Dark", tabName = "m_dark", icon = icon("map")),
        menuSubItem("Earthquake Heat", tabName = "m_heat", icon = icon("map")),
        #Weather api
        menuSubItem("Weather OWMR", tabName = "m_weather", icon = icon("air"))
      )
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "m_osm",
        tags$style(type = 'text/css', '#earthq_osm {height: calc(100vh-150px) 
                   !important')
      )
    )
  )
)

server <- function(input, output, session){
  data("quakes")
  
  output$earthq_osm <- renderLeaflet({
    pal <- colorNumeric("Blues", quakes$mag)
    
    leaflet(data = quakes) %>% addTiles(group = "OpenStreetMap") %>% 
      
      addProviderTiles(providers$Esri.WorldStreetMap, options = tileOptions(
        minZoom = 1, maxZoom = 7), group = "Esri.WorldStreetMap") %>%
      addProviderTiles(providers$Esri.WorldImagery, options = tileOptions(
        minZoom = 7, maxZoom = 13), group = "Esri.WorldImagery") %>%
      
      addCircles(radius = 10^mag/10, weight = 1, color = ~pal(mag), 
                 fillOpacity = 0.7, popup = ~as.character(mag), 
                 label = ~as.character(mag), group = "Points") %>%
      
      addLayersControl(
        baseGroups = c("OpenStreetMap", "Esri.WorldStreetMap", "Esri.WorldImagery"),
        overlayGroups = c("Markers"),
        
        options = layersControlOptions(collapsed = TRUE)
      ) %>%
      
      addLegend(
        position = "topright",
        pal = pal,
        values = ~mag,
        group = "Points",
        title = "Магнитуда землетрясений v1"
      )
  })
  shinyApp(ui, server)
}