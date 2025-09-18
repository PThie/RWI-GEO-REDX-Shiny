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
    suppressWarnings(grids_munic <- data.table::fread(
        file.path(
            config_paths()[["gebiete_path"]],
            "Zuordnung",
            "Raster_Gemeinde",
            "2019_Grids_Municipality_Exact_unambiguous.csv"
        )
    ))

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

    # combination of grids and city districts
    suppressWarnings(grids_city_districts <- data.table::fread(
        file.path(
            config_paths()[["gebiete_path"]],
            "Zuordnung",
            "Raster_Stadtteil",
            "grid-centroid",
            "Zuordnung_r1_stadtteil.csv"
        )
    ))

    # combination of grids and zip-codes
    grids_zip <- data.table::fread(
        file.path(
            config_paths()[["gebiete_path"]],
            "Zuordnung",
            "Raster_PLZ",
            "raster_plz_2019_unambiguous.csv"
        )
    )

    # city district names
    city_district_names <- haven::read_dta(
        file.path(
            config_paths()[["gebiete_path"]],
            "Stadtteile",
            "_Stadtteile infas360",
            "ortsteile_namen.dta"
        )
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

    grids_city_districts <- grids_city_districts |>
        dplyr::select(r1_id, ags11) |>
        merge(
            city_district_names |>
                dplyr::select(city_district = ortsteil, ags11) |>
                dplyr::mutate(
                    city_district = dplyr::case_when(
                        is.na(city_district) ~ "No information",
                        TRUE ~ city_district
                    )
                ),
            by = "ags11",
            all.x = TRUE
        ) |>
        dplyr::select(-ags11)

    # merge all
    grids_munic <- grids_munic |>
        merge(
            grids_city_districts,
            by.x = "grid",
            by.y = "r1_id",
            all.x = TRUE
        ) |>
        merge(
            grids_zip |>
                dplyr::rename(zipcode = PLZ),
            by.x = "grid",
            by.y = "idm",
            all.x = TRUE
        )

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