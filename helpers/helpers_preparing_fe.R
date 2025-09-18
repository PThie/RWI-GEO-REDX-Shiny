helpers_preparing_fe <- function() {
    #' @title Prepare FE data
    #' 
    #' @description This function prepares the fixed effects (FE) data by reading,
    #' aggregating to municipality level, and merging with municipality names.
    #' 
    #' @return None. The function exports the prepared FE data to a CSV file.
    #' @author Patrick Thiel

    #--------------------------------------------------
    # reading FE

    reading_fe <- function(housing_type = NA) {
        fe <- data.table::fread(
            file.path(
                config_paths()[["data_path"]],
                paste0(
                    "fixed_effects_grids_year_absolute_logged_",
                    housing_type,
                    ".csv"
                )
            )
        )

        # add housing type
        fe$housing_type <- housing_type

        # keep only variables needed
        fe <- fe |>
            dplyr::select(
                year,
                pindex_FE,
                grid,
                nobs_grid,
                gid2019,
                nobs_munic,
                housing_type
            )


        return(fe)
    }

    #--------------------------------------------------
    # aggregate to higher level
    # NOTE: aggregation to municipality level
    # NOTE: same strategy as in REDX

    aggregating_fe <- function(data) {
        # add weights based on NOBS
        data <- data |>
            dplyr::mutate(
                weight = nobs_grid / nobs_munic,
                weighted_pindex = pindex_FE * weight
            )

        # aggregate to municipality level
        data_munic <- data |>
            dplyr::group_by(
                year,
                gid2019
            ) |>
            dplyr::summarise(
                housing_type = dplyr::first(housing_type),
                weighted_pindex = sum(weighted_pindex, na.rm = TRUE)
            ) |>
            dplyr::ungroup()

        # return
        return(data_munic)
    }

    hk_fe <- "HK" |>
        reading_fe() |>
        aggregating_fe()

    wk_fe <- "WK" |>
        reading_fe() |>
        aggregating_fe()

    wm_fe <- "WM" |>
        reading_fe() |>
        aggregating_fe()

    # combine all
    all_fe <- dplyr::bind_rows(
        hk_fe,
        wk_fe,
        wm_fe
    )

    # add leading zero to gid2019
    all_fe <- all_fe |>
        dplyr::mutate(
            gid2019 = stringr::str_pad(
                gid2019,
                width = 8,
                side = "left",
                pad = "0"
            )
        )

    #--------------------------------------------------
    # read municipalities (for names)

    munics <- sf::st_read(
        file.path(
            config_paths()[["gebiete_path"]],
            "Gemeinde",
            "2019",
            "VG250_GEM.shp"
        ),
        quiet = TRUE
    ) |>
    sf::st_drop_geometry() |>
    dplyr::distinct(AGS, .keep_all = TRUE)

    # merge names to FE
    all_fe <- all_fe |>
        merge(
            munics |>
                dplyr::select(AGS, gid_name = GEN),
            by.x = "gid2019",
            by.y = "AGS",
            all.x = TRUE
        )

    #--------------------------------------------------
    # export

    arrow::write_parquet(
        all_fe,
        file.path(
            config_paths()[["data_path"]],
            "fe_munic_abs_logged.parquet"
        )
    )
}
