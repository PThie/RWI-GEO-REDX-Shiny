server <- function(input, output, session) {
    #--------------------------------------------------
    # extract user input

    var_of_interest <- reactive({
        req(input$select_year)

        var <- paste0(
            "pindex",
            input$select_year
        )

        var
    })

    #--------------------------------------------------
    # filter for housing type (choice of user)

    housing_type_data <- reactive({
        req(
            input$select_housing_type,
            input$select_year,
            var_of_interest()
        )

        # data preparation
        filtered <- redx_data |>
            dplyr::filter(
                housing_type == input$select_housing_type
            ) |>
            # TODO: DELETE LATER
            dplyr::filter(grid %in% c(
                "4110_3152",
                "4110_3153",
                "4111_3154",
                "4112_3150",
                "4112_3152",
                "4113_3151",
                "4113_3154",
                "4114_3151",
                "4114_3152",
                "4114_3153",
                "4115_3150"
            )) |>
            dplyr::select(
                grid,
                housing_type,
                city_name,
                dplyr::all_of(var_of_interest())
            ) |>
            dplyr::mutate(
                # define popup text
                # TODO: handle NAs in city_name
                popup_text = glue::glue(
                    "<div style='width:250px; font-family:Calibri, sans-serif;'>",
                        "<p style = \"font-size:100%; color:grey; margin:0\">Grid in:</p>",
                        "<p style = \"font-size:140%; margin:0;\">{city_name}</p>",
                    "</div>",
                    "<hr style='margin: 4px 0;'/>"
                )
            )

        filtered
    })

    # output$tst <- renderTable({housing_type_data()})

    #--------------------------------------------------
    # create map
    # NOTE: for background maps check: https://leaflet-extras.github.io/leaflet-providers/preview/

    output$map <- leaflet::renderLeaflet({
        req(
            housing_type_data(),
            var_of_interest()
        )

        # retrieve needed information
        filtered_data <- housing_type_data()
        var_name <- var_of_interest()

        # define color palette
        pal <- leaflet::colorNumeric(
            palette = "plasma",
            domain = filtered_data[[var_name]]
        )

        # for performance reasons, simplify the sf object
        # TODO: check if this is really needed
        simplified_sf <- rmapshaper::ms_simplify(
            filtered_data,
            keep = 0.05,
            keep_shapes = TRUE
        )

        # create actual map
        leaflet::leaflet(options = leafletOptions(preferCanvas = TRUE)) |>
            leaflet::addProviderTiles(
                providers$CartoDB.Positron
            ) |>
            leaflet::setView(
                lng = essen_centroid_coords$lon,
                lat = essen_centroid_coords$lat,
                zoom = 12
            ) |>
            leafgl::addGlPolygons(
                data = filtered_data,
                #--------------------------------------------------
                # border layout of the grids
                color = "transparent", # border color
                weight = 0, # border thickness
                #--------------------------------------------------
                # fill layout of the grids
                fillColor = pal(filtered_data[[var_name]]),
                fillOpacity = 0.9,
                popup = ~ popup_text
            ) |>
            # Overlay map labels on top
            leaflet::addProviderTiles(leaflet::providers$CartoDB.PositronOnlyLabels) |>
            leaflet::addLegend(
                position = "bottomright",
                pal = pal,
                opacity = 0.9,
                values = filtered_data[[var_name]]
            ) |>
            #--------------------------------------------------
            # add special features (fullscreen, search, reset)
            leaflet.extras::addFullscreenControl() |>
            leaflet.extras::addSearchOSM(
                options = leaflet.extras::searchOptions(
                    zoom = 13,
                    autoCollapse = TRUE,
                    hideMarkerOnCollapse = TRUE
                )
            ) |>
            leaflet.extras::addResetMapButton()
    })


}