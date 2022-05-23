library(shiny)
library(vroom)
library(dplyr)
library(janitor)
library(leaflet)

colores <- vroom::vroom("data/colores.tsv", na = "")
pozos <- vroom::vroom("data/calidad_agua_subterranea_2020.tsv", na = "",
                      col_types = cols("DUR_mg/L" = col_character(),
                                       "FLUORUROS_mg/L" = col_character(),
                                       "SDT_M_mg/L" =col_character())) %>%
    janitor::clean_names() %>% 
    select(-periodo, -starts_with("cumple"), -sdt_mg_l) %>%
    mutate(popup = paste0("<b>", clave, "</b><br/>", sitio))

vars <- c(
  "semaforo" = "Semáforo",
  "calidad_alc" = "CALIDAD_ALC",
  "calidad_as" = "CALIDAD_AS",
  "calidad_cd" = "CALIDAD_CD",
  "calidad_coli_fec" = "CALIDAD_COLI_FEC", 
  "calidad_conduc" = "CALIDAD_CONDUC",
  "calidad_cr" = "CALIDAD_CR",
  "calidad_dur" = "CALIDAD_DUR",
  "calidad_fe" = "CALIDAD_FE",
  "calidad_fluo" = "CALIDAD_FLUO",
  "calidad_hg" = "CALIDAD_HG",
  "calidad_mn" = "CALIDAD_MN",
  "calidad_n_no3" = "CALIDAD_N_NO3",
  "calidad_pb" = "CALIDAD_PB",
  "calidad_sdt_ra" = "CALIDAD_SDT_ra",
  "calidad_sdt_salin" = "CALIDAD_SDT_salin"
)
cuencas <-pozos %>% pull(organismo_de_cuenca) %>% unique()

function(input, output, session) {
  
  ## Interactive Map ###########################################
  
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(options = providerTileOptions(minZoom = 4))%>%
      setView(lng = -103.4528147, lat = 24.4979901, zoom = 4)
  })
  
  showPozoPopup <- function(clave, lat, lng) {
    selectedPozo <- pozos[pozos$clave == clave,]
    leafletProxy("map") %>% addPopups(lng, lat, selectedPozo$popup)
  }
  
  pozosInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(pozos[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(pozos,
           latitude >= latRng[1] & latitude <= latRng[2] &
             longitude >= lngRng[1] & longitude <= lngRng[2])
  })
  
  output$check_cuencas <- renderUI({checkboxGroupInput("check_cuencas",
  "Organismo de cuenca", choices = cuencas, selected = cuencas)})
  
  # # This observer is responsible for maintaining the circles and legend,
  # # according to the variables the user has chosen to map to color and size.
  observe({
    colorBy <- input$color
    
    colores_cat <- colores %>%
      filter(column == colorBy) %>%
      select(-column) %>%
      arrange(orden) 
    
    sel_cuencas <- input$check_cuencas
    
    pozos_color <- pozos %>% 
      inner_join(colores_cat, by = setNames("nivel", colorBy)) %>%
      filter(organismo_de_cuenca %in% sel_cuencas)
  
    leafletProxy("map", data = pozos_color) %>%
      clearMarkers() %>%
      addCircleMarkers(~longitud, ~latitud, fillOpacity=0.7, popup = ~popup,
                       stroke = FALSE, radius = 7, fillColor=~color) %>%
      addLegend("bottomleft", colors = colores_cat$color, labels = colores_cat$nivel, na.label = "NA", 
                values=colores_cat$nivel, title = unname(vars[colorBy]), layerId="colorLegend")
     
  })
  
  ## Data Explorer ###########################################
  
  observe({
    municipios <- if (is.null(input$estados)) character(0) else {
      pozos %>% 
        filter(estado %in% input$estados) %>%
        pull(municipio) %>%
        sort() %>% unique()
    }
    stillSelected <- isolate(input$municipios[input$municipios %in% municipios])
    updateSelectizeInput(session, "municipios", choices = municipios,
                         selected = stillSelected, server = TRUE)
  })
  
  observe({
    if (is.null(input$goto))
      return()
    isolate({
      map <- leafletProxy("map")
      map %>% clearPopups()
      dist <- 0.5
      lat <- input$goto$lat
      long <- input$goto$long
      pozo <- input$goto$pozo
      showPozoPopup(pozo, lat, long)
      map %>% fitBounds(long - dist, lat - dist, long + dist, lat + dist)
    })
  })
  
  output$pozostable <- DT::renderDataTable({
    pozos_df <- pozos %>%
      filter(is.null(input$estados) | estado %in% input$estados,
            is.null(input$municipios) | municipio %in% input$municipios) %>%
      select(-popup) %>%
      mutate(localizar = paste('<a class="go-map" href="" data-lat="', latitud, '" data-long="', longitud, '" data-pozo="', clave, '"><i class="fa fa-crosshairs"></i></a>', sep=""))
    action <- DT::dataTableAjax(session, pozos_df, outputId = "pozostable")

    DT::datatable(pozos_df, options = list(ajax = list(url = action)), escape = FALSE)
  })
  
  
}