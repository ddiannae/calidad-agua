library(shiny)
library(vroom)
library(dplyr)
library(janitor)
library(leaflet)
library(htmltools)

iconos = awesomeIconList(Amarillo = makeAwesomeIcon(markerColor = 'yellow', iconColor = 'black'), 
           Rojo = makeAwesomeIcon(markerColor = 'red', library='fa', iconColor = 'black'), 
           Verde = makeAwesomeIcon(markerColor = 'green', library='ion'))

pozos <- vroom::vroom("data/calidad_agua_subterranea_2020.tsv") %>%
  janitor::clean_names()

pozos <- pozos %>% 
  mutate(popup = paste0( clave, "\n", sitio))
  

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

ui <- fluidPage(
  leafletOutput("mymap")
)

server <- function(input, output, session) {
  
  pozos_filtered <- eventReactive(input$recalc, {
    pozos
  }, ignoreNULL = FALSE)
  
  output$mymap <- renderLeaflet({
    leaflet(data = pozos_filtered()) %>%
      addTiles(options = providerTileOptions(minZoom = 4)) %>%
      addAwesomeMarkers(lat = ~latitud, lng = ~longitud, popup = ~htmlEscape(popup), 
                        icon = ~iconos[semaforo])
  })
  

 
}

shinyApp(ui, server)