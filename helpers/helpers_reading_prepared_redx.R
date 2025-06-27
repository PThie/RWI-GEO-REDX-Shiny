helpers_reading_prepared_redx <- function() {
    #' @title Read prepared REDX data
    #' 
    #' @description This function reads the prepared REDX data from a specified
    #' file path.
    #' 
    #' @return Spatial dataframe with prepared REDX data.
    #' @author Patrick Thiel
    
    #--------------------------------------------------
    # read prepared REDX data

    redx_data <- sf::st_read(
        file.path(
            config_paths()[["data_path"]],
            "redx_data_prep_sf.gpkg"
        ),
        quiet = TRUE
    )

    #--------------------------------------------------
    # return

    return(redx_data)
}