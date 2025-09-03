#--------------------------------------------------
# start front end

ui <- shiny::navbarPage(
    title = "RWI-GEO-REDX",
    id = "navbar",
    shiny::tabPanel(
        title = "Interactive Map",
        div(
            class = "outer",
            tags$head(
                shiny::includeCSS("www/styles.css")
            ),
            leaflet::leafletOutput("map", height = "100%", width = "100%"),
            shiny::absolutePanel(
                id = "options-map",
                class = "panel panel-default", 
                fixed = TRUE,
                draggable = TRUE,
                top = 60,
                left = "auto",
                right = 20,
                bottom = "auto",
                width = 340,
                height = "auto",
                h2("Map - Options"),
                selectInput(
                    inputId = "selecteded_housing_type",
                    label = "Select housing type:",
                    choices = list(
                        "House sales" = "HK",
                        "Apartment sales" = "WK",
                        "Apartment rents" = "WM"
                    ),
                    # set default value
                    selected = "WM"
                ),
                selectInput(
                    inputId = "selected_year",
                    label = "Select year:",
                    choices = seq(2008, config_globals()[["max_year"]], by = 1),
                    # set default value
                    selected = config_globals()[["max_year"]]
                )
            )
        ),
        tags$div(
            id = "cite",
            "Data source: RWI-GEO-REDX",
            tags$a(
                "RWI Real Estate Data",
                href = "https://www.rwi-essen.de/en/research-advice/further/research-data-center-ruhr-fdz/data-sets/rwi-geo-red/x-real-estate-data-and-price-indices"
            )
        )
    ),
    shiny::tabPanel(
        title = "Build Your Rent",
        h2("Input your factors and calculate your rent/price")
    )
)