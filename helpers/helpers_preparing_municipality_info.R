helpers_preparing_municipality_info <- function() {
    #' @title Preparing municipality information
    #' 
    #' @description This function reads the municipality information and
    #' combines it with the grid information.
    #' 
    #' @return Dataframe with grid and municipality information.
    #' @author Patrick Thiel

    #--------------------------------------------------
    # read data

    # combination between municipalities and grids
    grids_munic <- data.table::fread(
        file.path(
            config_paths()[["gebiete_path"]],
            "Zuordnung",
            "Raster_Gemeinde",
            "2019_Grids_Municipality_Exact_unambiguous.csv"
        )
    )

    # municipality information
    munics_sf <- sf::st_read(
        file.path(
            config_paths()[["gebiete_path"]],
            "Gemeinde",
            "2019",
            "VG250_GEM.shp"
        ),
        quiet = TRUE
    )

    #--------------------------------------------------
    # clean combination data

    grids_munic <- grids_munic |>
        dplyr::mutate(
            AGS = as.character(AGS),
            AGS = stringr::str_pad(AGS, 8, pad = "0" )
        ) |>
        dplyr::select(-share) |>
        dplyr::rename(grid = r1_id)

    #--------------------------------------------------
    # clean municipality information

    munics <- munics_sf |>
        sf::st_drop_geometry() |>
        dplyr::select(AGS, city_name = GEN)

    #--------------------------------------------------
    # combine both datasets

    grids_munic_info <- merge(
        grids_munic,
        munics,
        by = "AGS",
        all.x = TRUE
    )

    #--------------------------------------------------
    # return

    return(grids_munic_info)
}