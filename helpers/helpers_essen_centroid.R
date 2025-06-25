helpers_essen_centroid <- function() {
    #' @title Getting centroid of Essen
    #' 
    #' @description This function reads the shapefiles of the counties and finds
    #' the centroid of the county of Essen.
    #' 
    #' @return Dataframe with centroid coordinates (longitude and latitude).
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
    # return

    return(essen_centroid_coords)
}