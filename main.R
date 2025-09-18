#--------------------------------------------------
# source files

source("config.R")

lapply(
    list.files(
        file.path(
            here::here(),
            "helpers"
        ),
        full.names = TRUE
    ),
    source
)

#--------------------------------------------------
# preparation

# Prepare REDX data
helpers_preparing_redx_data(
    file_name_abs = "RWIGEOREDX_GRIDS_V15_PUF_YEAR_ABS",
    file_name_dev_abs = "RWIGEOREDX_GRIDS_V15_PUF_YEAR_DEV_CROSS",
    file_name_dev_perc = "RWIGEOREDX_GRIDS_V15_PUF_YEAR_DEV_PERC_CROSS",
    file_name_dev_abs_region = "RWIGEOREDX_GRIDS_V15_PUF_YEAR_DEV_REGION",
    file_name_dev_perc_region = "RWIGEOREDX_GRIDS_V15_PUF_YEAR_DEV_PERC_REGION"
)

# Prepare FE data
helpers_preparing_fe()

# Prepare model coefficients and smearing factors
helpers_preparing_model_coefs()

# Essen centroid coordinates
helpers_essen_centroid()
