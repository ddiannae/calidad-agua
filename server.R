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
    cities <- if (is.null(input$states)) character(0) else {
      filter(cleantable, State %in% input$states) %>%
        `$`('City') %>%
        unique() %>%
        sort()
    }
    stillSelected <- isolate(input$cities[input$cities %in% cities])
    updateSelectizeInput(session, "cities", choices = cities,
                         selected = stillSelected, server = TRUE)
  })
  
  observe({
    zipcodes <- if (is.null(input$states)) character(0) else {
      cleantable %>%
        filter(State %in% input$states,
               is.null(input$cities) | City %in% input$cities) %>%
        `$`('Zipcode') %>%
        unique() %>%
        sort()
    }
    stillSelected <- isolate(input$zipcodes[input$zipcodes %in% zipcodes])
    updateSelectizeInput(session, "zipcodes", choices = zipcodes,
                         selected = stillSelected, server = TRUE)
  })
  
  observe({
    if (is.null(input$goto))
      return()
    isolate({
      map <- leafletProxy("map")
      map %>% clearPopups()
      dist <- 0.5
      zip <- input$goto$zip
      lat <- input$goto$lat
      lng <- input$goto$lng
      showZipcodePopup(zip, lat, lng)
      map %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist)
    })
  })
  
  output$ziptable <- DT::renderDataTable({
    # df <- cleantable %>%
    #   filter(
    #     Score >= input$minScore,
    #     Score <= input$maxScore,
    #     is.null(input$states) | State %in% input$states,
    #     is.null(input$cities) | City %in% input$cities,
    #     is.null(input$zipcodes) | Zipcode %in% input$zipcodes
    #   ) %>%
    #   mutate(Action = paste('<a class="go-map" href="" data-lat="', Lat, '" data-long="', Long, '" data-zip="', Zipcode, '"><i class="fa fa-crosshairs"></i></a>', sep=""))
    # action <- DT::dataTableAjax(session, df, outputId = "ziptable")
    # 
    # DT::datatable(df, options = list(ajax = list(url = action)), escape = FALSE)
    DT::datatable(pozos)
  })
  
  
}