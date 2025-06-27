helpers_transforming_redx_parquet <- function() {
    #' @title Transform REDX parquet data
    #' 
    #' @description This function reads the original REDX data and transforms it
    #' into the parquet format for faster handling.
    #' 
    #' @return NULL, direct export
    #' @author Patrick Thiel
    
    #--------------------------------------------------
    # read data

    # PUF RWI-GEO-REDX data
    redx_data <- openxlsx::read.xlsx(
        file.path(
            config_paths()[["redx_data"]],
            paste0(
                "RWIGEOREDX_GRIDS_v",
                config_globals()[["redx_version"]],
                "_PUF.xlsx"
            )
        ),
        sheet = "Grids_RegionEff_abs_yearly"
    )

    #--------------------------------------------------
    # export

    arrow::write_parquet(
        redx_data,
        file.path(
            config_paths()[["data_path"]],
            "redx_data_puf.parquet"
        )
    )

    #--------------------------------------------------
    # return

    return(NULL)
}