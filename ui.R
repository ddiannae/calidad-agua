library(leaflet)

estados <- c("AGUASCALIENTES",
             "BAJA CALIFORNIA SUR",
             "BAJA CALIFORNIA",
             "CAMPECHE",
             "CHIAPAS",
             "CHIHUAHUA",
             "COAHUILA DE ZARAGOZA",
             "COLIMA",
             "DISTRITO FEDERAL",
             "DURANGO",
             "GUANAJUATO",
             "GUERRERO",
             "HIDALGO",
             "JALISCO",
             "MEXICO",
             "MICHOACAN DE OCAMPO",
             "MORELOS",
             "NAYARIT",
             "NUEVO LEON",
             "OAXACA",
             "PUEBLA",
             "QUERETARO ARTEAGA",
             "QUINTANA ROO",
             "SAN LUIS POTOSI",
             "SINALOA",
             "SONORA",
             "TABASCO",
             "TAMAULIPAS",
             "TLAXCALA",
             "VERACRUZ DE IGNACIO DE LA LLAVE",
             "YUCATAN",
             "ZACATECAS")

# Choices for drop-downs
vars <- c(
  "Semáforo"= "semaforo",
  "CALIDAD_ALC"= "calidad_alc",
  "CALIDAD_AS"= "calidad_as",
  "CALIDAD_CD"= "calidad_cd",
  "CALIDAD_COLI_FEC"= "calidad_coli_fec",
  "CALIDAD_CONDUC"= "calidad_conduc",
  "CALIDAD_CR"= "calidad_cr",
  "CALIDAD_DUR"= "calidad_dur",
  "CALIDAD_FE"= "calidad_fe",
  "CALIDAD_FLUO"= "calidad_fluo",
  "CALIDAD_HG"= "calidad_hg",
  "CALIDAD_MN"= "calidad_mn",
  "CALIDAD_N_NO3"= "calidad_n_no3",
  "CALIDAD_PB"= "calidad_pb",
  "CALIDAD_SDT_ra"= "calidad_sdt_ra",
  "CALIDAD_SDT_salin"= "calidad_sdt_salin"
)


navbarPage("Calidad del agua en México", id="nav",
  tabPanel("Mapa Interactivo",
    div(class="outer",
        
        tags$head(
          # Include our custom CSS
          includeCSS("styles.css"),
          includeScript("gomap.js")
        ),
        
        # If not using custom CSS, set height of leafletOutput to a number instead of percent
        leafletOutput("map", width="100%", height="100%"),
        # Shiny versions prior to 0.11 should use class = "modal" instead.
        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                      width = 330, height = "auto",
                      h2("Pozos"),
                      checkboxInput("verheat", "Mostrar Heatmap de Semáforo", TRUE),
                      selectInput("color", "Selecciona la variable para ajustar color", vars),
                      uiOutput("check_cuencas")
        ),
    )
  ),
           
  tabPanel("Explorador de datos",
    fluidRow(
      column(4,
             selectInput("estados", "Estado", c("Todos"="", structure(estados, names=estados)), multiple=TRUE)
      ),
      column(4,
             conditionalPanel("input.estados",
                              selectInput("municipios", "Municipios", c("Todos"=""), multiple=TRUE)
             )
      )
    ),
    hr(),
    DT::dataTableOutput("pozostable")
  ),
  
  conditionalPanel("false", icon("crosshairs"))
)
