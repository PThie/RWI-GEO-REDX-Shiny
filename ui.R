#--------------------------------------------------
# start front end

ui <- shinydashboard::dashboardPage(
    shinydashboard::dashboardHeader(
        title = "RWI-GEO-REDX"
    ),

    shinydashboard::dashboardSidebar(
        collapsed = TRUE,
        shinydashboard::sidebarMenu(
            id = "sidebar",
            shinydashboard::menuItem(
                text = "Options",
                icon = shiny::icon("gears")
            )
        ),
        selectInput(
            inputId = "select_housing_type",
            label = "Select housing type:",
            choices = list(
                "House sales" = "HK",
                "Apartment sales" = "WK",
                "Apartment rents" = "WM",
                "Combined" = "CI"
            ),
            # set default value
            selected = "CI"
        ),
        selectInput(
            inputId = "select_year",
            label = "Select year:",
            choices = seq(2008, config_globals()[["max_year"]], by = 1),
            # set default value
            selected = config_globals()[["max_year"]]
        )
    ),

    shinydashboard::dashboardBody(
        leaflet::leafletOutput("map", height = "100vh")
        # tableOutput("tst")
    )
)