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
    library(shinyBS)
    library(bslib)
    library(jsonlite)
    library(jsonify)
    library(here)
    library(qs)
})

#--------------------------------------------------
# source files

lapply(
    list.files(
        file.path(
            here::here(),
            "helpers"
        ),
        full.names = TRUE
    ),
    source
)

#--------------------------------------------------
# globals

max_year <- 2024

#--------------------------------------------------
# read data

# PUF RWI-GEO-REDX data
redx_data <- helpers_reading_prepared_redx()

# Essen centroid
essen_centroid_coords <- data.table::fread(
    file.path(
        here::here(),
        "data",
        "essen_centroid_coords.csv"
    )
)

# Model information
hedonic_model_coefs <- helpers_reading_model_coefs()
smearing_factors <- helpers_reading_smearing_factors()

#--------------------------------------------------
message("loaded global.R")