helpers_preparing_redx_data <- function() {
    #' @title Preparing RWI-GEO-REDX data
    #' 
    #' @description This function reads the RWI-GEO-REDX data and prepares it
    #' for further plotting.
    #' 
    #' @return Spatial dataframe with RWI-GEO-REDX data and grid information.
    #' @author Patrick Thiel
    
    #--------------------------------------------------
    # read data

    # PUF RWI-GEO-REDX data
    redx_data <- arrow::read_parquet(
        file.path(
            config_paths()[["data_path"]],
            "redx_data_puf.parquet"
        )
    )

    # grid information
    grids_sf <- sf::st_read(
        file.path(
            config_paths()[["gebiete_path"]],
            "Raster",
            "ger_1km_rectangle",
            "ger_1km_rectangle.shp"
        ),
        quiet = TRUE
    )

    # grid and municipality information
    grids_munic <- helpers_preparing_municipality_info()

    #--------------------------------------------------
    # clean grids

    grids_sf <- grids_sf |>
        dplyr::select(-id) |>
        sf::st_transform(config_globals()[["gps_crs"]])

    #--------------------------------------------------
    # clean REDX data

    redx_data_prep <- redx_data |>
        dplyr::select(-dplyr::contains("NOBS"))

    # merge municipality information
    redx_data_prep <- merge(
        redx_data_prep,
        grids_munic,
        by = "grid",
        all.x = TRUE
    )

    # export parquet
    arrow::write_parquet(
        redx_data_prep,
        file.path(
            config_paths()[["data_path"]],
            "redx_data_prep.parquet"
        )
    )

    #--------------------------------------------------
    # merge both datasets

    redx_data_sf <- merge(
        redx_data_prep,
        grids_sf,
        by.x = "grid",
        by.y = "idm",
        all.x = TRUE
    )
    
    redx_data_sf <- sf::st_set_geometry(
        redx_data_sf,
        redx_data_sf$geometry
    )

    # export
    sf::st_write(
        redx_data_sf,
        file.path(
            config_paths()[["data_path"]],
            "redx_data_prep_sf.gpkg"
        ),
    )

    #--------------------------------------------------
    # return

    return(redx_data_sf)
}