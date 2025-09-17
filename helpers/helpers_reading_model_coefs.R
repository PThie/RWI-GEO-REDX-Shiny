helpers_reading_model_coefs <- function() {
    #' @title Read model coefficients
    #' 
    #' @description This function reads the model coefficients from a parquet file.
    #' 
    #' @return Dataframe containing the model coefficients.
    #' @author Patrick Thiel

    #--------------------------------------------------
    # read model

    model <- arrow::read_parquet(
        file.path(
            here::here(),
            "data",
            "model_coefficients_prep.parquet"
        )
    )

    #--------------------------------------------------
    # return

    return(model)
}