server <- function(input, output, session) {
    #--------------------------------------------------
    # extract user input

    var_of_interest <- reactive({
        req(input$selected_year)

        var <- paste0(
            "pindex",
            input$selected_year
        )

        var
    })

    var_deviation <- reactive({
        req(input$selected_year)

        var <- paste0(
            "pindex",
            input$selected_year,
            "_dev_abs"
        )

        var
    })

    var_deviation_perc <- reactive({
        req(input$selected_year)

        var <- paste0(
            "pindex",
            input$selected_year,
            "_dev_perc"
        )

        var
    })

    #--------------------------------------------------
    # filter for housing type (choice of user)

    housing_type_data <- reactive({
        req(
            input$selecteded_housing_type,
            input$selected_year,
            var_of_interest(),
            var_deviation(),
            var_deviation_perc()
        )

        # define label for price/ rent in popup
        if (input$selecteded_housing_type == "WM") {
            price_label <- "Rent"
        } else {
            price_label <- "Price"
        }

        # data preparation
        filtered <- redx_data |>
            dplyr::filter(
                housing_type == input$selecteded_housing_type
            ) |>
            # TODO: DELETE LATER
            # dplyr::filter(grid %in% c(
            #     "4110_3152",
            #     "4110_3153",
            #     "4111_3154",
            #     "4112_3150",
            #     "4112_3152",
            #     "4113_3151",
            #     "4113_3154",
            #     "4114_3151",
            #     "4114_3152",
            #     "4114_3153",
            #     "4115_3150"
            # )) |>
            dplyr::filter(
                substring(AGS, 1, 2) %in% c("05", "06", "07")
            ) |>
            dplyr::select(
                grid,
                housing_type,
                city_name,
                dplyr::all_of(var_of_interest()),
                dplyr::all_of(var_deviation()),
                dplyr::all_of(var_deviation_perc())
            ) |>
            dplyr::mutate(
                # add price label as column (needed for popup text)
                price_label = price_label,
                # define popup text
                # TODO: handle NAs in city_name
                popup_text = glue::glue(
                    "<div style='width:250px; font-family:Calibri, sans-serif;'>",
                        "<p style = \"font-size:100%; color:grey; margin:0;\">Grid in:</p>",
                        "<p style = \"font-size:140%; margin:0;\">{city_name}</p>",
                    "</div>",
                    "<hr style='margin: 4px 0;'/>",
                    # Price information
                    "<div style='width:250px; font-family:Calibri, sans-serif;'>",
                        "<p style = \"font-size:100%; color:grey; margin:0;\">{price_label}</p>",
                        "<p style = \"font-size:140%; margin:0;\">{
                            ifelse(
                                is.na(get(var_of_interest())),
                                'No data',
                                paste0(
                                    scales::comma(round(get(var_of_interest()), 2), accuracy = 0.01),
                                    ' &euro;/m&sup2;'
                                )
                            )
                        }</p>",
                    "</div>",
                    # Deviation information (absolute + percentage)
                    "<div style='width:250px; font-family:Calibri, sans-serif;'>",
                        "<p style = \"font-size:100%; color:grey; margin:0;\">Change rel. to German average:</p>",
                        "<p style = \"font-size:140%; margin:0;\">{
                            ifelse(
                                is.na(get(var_deviation())),
                                'No data',
                                paste0(
                                    scales::comma(round(get(var_deviation()), 2), accuracy = 0.01),
                                    ' &euro;/m&sup2; (',
                                    scales::comma(round(get(var_deviation_perc()), 2), accuracy = 0.01),
                                    '%)'
                                )
                            )
                        }</p>",
                    "</div>"
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

        # define title for legend
        if (unique(filtered_data[["housing_type"]]) == "WM") {
            legend_title <- paste0(
                "Rent (",
                "\U20AC",
                "/m",
                "\u00B2",
                ")"
            )
        } else {
            legend_title <- paste0(
                "Price (",
                "\U20AC",
                "/m",
                "\u00B2",
                ")"
            )
        }

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
                popup = ~ popup_text,
                na.color = "#f0f0f0"
            ) |>
            # Overlay map labels on top
            leaflet::addProviderTiles(leaflet::providers$CartoDB.PositronOnlyLabels) |>
            leaflet::addLegend(
                position = "bottomright",
                pal = pal,
                opacity = 0.9,
                values = filtered_data[[var_name]],
                na.label = "No data",
                title = legend_title
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