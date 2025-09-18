helpers_reading_fe <- function() {
    #' @title Read regional FE data
    #' 
    #' @description This function reads the regional FE data.
    #' 
    #' @return Dataframe containing the regional FE data.
    #' @author Patrick Thiel

    #--------------------------------------------------
    # read regional FE data

    regional_fe_data <- arrow::read_parquet(
        file.path(
            here::here(),
            "data",
            "fe_munic_abs_logged.parquet"
        )
    )

    #--------------------------------------------------
    # set as data.table

    data.table::setDT(regional_fe_data)

    #--------------------------------------------------
    # return

    return(regional_fe_data)
}