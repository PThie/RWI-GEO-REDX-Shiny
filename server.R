server <- function(input, output, session) {
    #--------------------------------------------------
    # source config file

    source("config.R")

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
        sheet = "Grids_RegionEff_yearly"
    )

    # Essen centroid coordinates
    essen_centroid_coords <- data.table::fread(
        file.path(
            config_paths()[["data_path"]],
            "essen_centroid.csv"
        )
    )

    #--------------------------------------------------
    # filter for housing type (choice of user)

    housing_type_data <- reactive({
        req(input$select_housing_type)

        filtered <- redx_data |>
            dplyr::filter(
                housing_type == input$select_housing_type
            ) |>
            dplyr::filter(!is.na(pindex2008))

        print(nrow(filtered))
        filtered
    })

    output$tst <- renderTable({housing_type_data()})
    # output$tst <- renderTable(redx_data)
    #--------------------------------------------------
    # create map
    # NOTE: for background maps check: https://leaflet-extras.github.io/leaflet-providers/preview/

    # output$map <- leaflet::renderLeaflet(
    #     leaflet::leaflet() |>
    #         leaflet::addProviderTiles(
    #             providers$Esri.WorldTopoMap,
    #             options = leaflet::providerTileOptions(
    #                 noWrap = TRUE
    #             )
    #         ) |>
    #         leaflet::setView(
    #             lng = essen_centroid_coords$lon,
    #             lat = essen_centroid_coords$lat,
    #             zoom = 12
    #         )
    # )

}