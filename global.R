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
    library(leafgl)
    library(rmapshaper)
    library(stringr)
    library(glue)
})

#--------------------------------------------------
# source config file

source("config.R")

lapply(
    list.files(
        file.path(
            config_paths()[["project_path"]],
            "helpers"
        ),
        full.names = TRUE
    ),
    source
)

#--------------------------------------------------
# read data

# PUF RWI-GEO-REDX data
redx_data <- helpers_preparing_redx_data()

# Essen centroid coordinates
essen_centroid_coords <- helpers_essen_centroid()