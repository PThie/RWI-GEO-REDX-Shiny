helpers_preparing_model_coefs <- function() {
    #' @title Prepare model coefficients and smearing factors
    #' 
    #' @description This function reads the model coefficients and smearing factors
    #' for different housing types, combines them into single dataframes.
    #' 
    #' @return List containing dataframes for model coefficients and smearing factors.
    #' @author Patrick Thiel

    #--------------------------------------------------
    # define housing types
    
    housing_types <-c("WM", "WK", "HK")

    #--------------------------------------------------
    # read all coefficients

    coefs_list <- list()
    for (housing_type in housing_types) {
        # read data
        coefs <- data.table::fread(
            file.path(
                here::here(),
                "data",
                paste0(
                    "model_coefficients_year_absolute_",
                    housing_type,
                    ".csv"
                )
            )
        )

        # add housing type
        coefs <- coefs |>
            dplyr::mutate(
                housing_type = housing_type
            )

        # store data
        coefs_list[[housing_type]] <- coefs
    }

    # combine all data
    coefs <- data.table::rbindlist(coefs_list)

    # export
    arrow::write_parquet(
        coefs,
        file.path(
            here::here(),
            "data",
            "model_coefficients_prep.parquet"
        )
    )

    #--------------------------------------------------
    # read smearing factors

    smearing_factors_list <- list()
    for (housing_type in housing_types) {
        # read data
        smearing_factors <- data.table::fread(
            file.path(
                here::here(),
                "data",
                paste0(
                    "smearing_factor_year_absolute_",
                    housing_type,
                    ".csv"
                )
            )
        )

        # add housing type
        smearing_factors <- smearing_factors |>
            dplyr::mutate(
                housing_type = housing_type
            )

        # store data
        smearing_factors_list[[housing_type]] <- smearing_factors
    }

    # combine all data
    smearing_factors <- data.table::rbindlist(smearing_factors_list)

    # export
    arrow::write_parquet(
        smearing_factors,
        file.path(
            here::here(),
            "data",
            "smearing_factors_prep.parquet"
        )
    )

    #--------------------------------------------------
    # store everything in a list

    all_model_info <- list(
        "coefs" = coefs,
        "smearing_factors" = smearing_factors
    )

    #--------------------------------------------------
    # return

    return(all_model_info)
}