#--------------------------------------------------
# load libraries

suppressPackageStartupMessages({
    library(shiny)
    library(htmltools)
    library(shinyjs)
    library(leaflet)
    library(dplyr)
    library(glue)
    library(sf)
    library(openxlsx)
    library(data.table)
    library(shinydashboard)
})

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
                text = "Housing Types",
                icon = shiny::icon("home")
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
            )
        )
    ),

    shinydashboard::dashboardBody(
        #leaflet::leafletOutput("map", height = "100vh")
        tableOutput("tst")
    )
)