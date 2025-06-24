#--------------------------------------------------
# Description:

#' @title Getting centroid of Essen
#' 
#' @description This script read the shapefiles of the counties and finds the
#' centroid of the county of Essen.
#' 
#' @author Patrick Thiel

#--------------------------------------------------
# libraries

suppressPackageStartupMessages({
    library(sf)
})

#--------------------------------------------------
# source config file

source("config.R")

#--------------------------------------------------
# read counties

counties <- sf::st_read(
    file.path(
        config_paths()[["gebiete_path"]],
        "Kreis",
        "2019",
        "VG250_KRS.shp"
    ),
    quiet = TRUE
) |>
sf::st_transform(config_globals()[["gps_crs"]])

#--------------------------------------------------
# subset for Essen

essen <- counties |>
    dplyr::filter(
        AGS == "05113"
    )

#--------------------------------------------------
# calculate centroid

essen_centroid <- sf::st_centroid(essen)

# extract coordinates
essen_centroid_coords <- sf::st_coordinates(essen_centroid) |>
    as.data.frame() |>
    dplyr::rename(
        lon = X,
        lat = Y
    )

#--------------------------------------------------
# export

data.table::fwrite(
    essen_centroid_coords,
    file.path(
        config_paths()[["data_path"]],
        "essen_centroid.csv"
    ),
    row.names = FALSE
)
