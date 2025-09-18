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

    redx_data <- qs::qread(
        file.path(
            here::here(),
            "data",
            "redx_data_prep_sf.qs"
        )
    )

    #--------------------------------------------------
    # adjust geometry column name

    if ("geom" %in% names(redx_data)) {
        sf::st_geometry(redx_data) <- "geometry"
    }

    #--------------------------------------------------
    # set as data.table

    data.table::setDT(redx_data)

    #--------------------------------------------------
    # remove rows with NA grid / AGS only once

    redx_data <- redx_data[!is.na(grid) & !is.na(AGS)]

    #--------------------------------------------------
    # return

    return(redx_data)
}