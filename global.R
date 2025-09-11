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
redx_data <- helpers_reading_prepared_redx()

# Essen centroid coordinates
essen_centroid_coords <- helpers_essen_centroid()

# Model information
hedonic_model_coefs <- helpers_reading_model_coefs()
smearing_factors <- helpers_reading_smearing_factors()

#--------------------------------------------------
message("loaded global.R")