helpers_reading_smearing_factors <- function() {
    #' @title Read smearing factors
    #' 
    #' @description This function reads the smearing factors from a parquet file.
    #' 
    #' @return Dataframe containing the smearing factors.
    #' @author Patrick Thiel

    #--------------------------------------------------
    # read smearing factors

    smearing_factors <- arrow::read_parquet(
        file.path(
            here::here(),
            "data",
            "smearing_factors_prep.parquet"
        )
    )

    #--------------------------------------------------
    # return

    return(smearing_factors)
}