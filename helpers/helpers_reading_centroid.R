helpers_reading_centroid <- function() {
    #' @title Read Essen centroid coordinates
    #' 
    #' @description This function reads the Essen centroid coordinates from a CSV file.
    #' 
    #' @return Dataframe containing the Essen centroid coordinates.
    #' @author Patrick Thiel

    #--------------------------------------------------
    # read Essen centroid coordinates

    essen_centroid_coords <- data.table::fread(
        file.path(
            here::here(),
            "data",
            "essen_centroid_coords.csv"
        )
    )

    #--------------------------------------------------
    # return

    return(essen_centroid_coords)
}