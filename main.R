#--------------------------------------------------
# source config file

source("config.R")

#--------------------------------------------------
# preparation

# Prepare REDX data
helpers_preparing_redx_data(
    file_name_abs = "RWIGEOREDX_GRIDS_V15_PUF_YEAR_ABS",
    file_name_dev_abs = "RWIGEOREDX_GRIDS_V15_PUF_YEAR_DEV_CROSS",
    file_name_dev_perc = "RWIGEOREDX_GRIDS_V15_PUF_YEAR_DEV_PERC_CROSS"
)

# Prepare FE data
helpers_preparing_fe()

# Prepare model coefficients and smearing factors
helpers_preparing_model_coefs()

# Essen centroid coordinates
helpers_essen_centroid()
