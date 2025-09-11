server <- function(input, output, session) {
    #--------------------------------------------------
    # INTERACTIVE MAP tab
    #--------------------------------------------------

    #--------------------------------------------------
    # extract user input

    var_of_interest <- reactive({
        shiny::req(input$selected_year)

        var <- paste0(
            "pindex",
            input$selected_year
        )

        var
    })

    var_deviation <- reactive({
        shiny::req(input$selected_year)

        var <- paste0(
            "pindex",
            input$selected_year,
            "_dev_abs"
        )

        var
    })

    var_deviation_perc <- reactive({
        shiny::req(input$selected_year)

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
        shiny::req(
            input$selected_housing_type,
            input$selected_year,
            var_of_interest(),
            var_deviation(),
            var_deviation_perc()
        )

        # define label for price/ rent in popup
        if (input$selected_housing_type == "WM") {
            price_label <- "Rent"
        } else {
            price_label <- "Price"
        }

        # data preparation
        filtered <- redx_data |>
            dplyr::filter(
                housing_type == input$selected_housing_type
            ) |>
            # TODO: Check if that affects many grids/ munics
            dplyr::filter(!is.na(grid)) |>
            dplyr::filter(!is.na(AGS)) |>
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
            # dplyr::filter(
            #     substring(AGS, 1, 3) == "051"
            # ) |>
            # dplyr::filter(city_name == "Essen") |>
            # dplyr::filter(
            #     substring(AGS, 1, 2) %in% c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16")
            # ) |>
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

    #--------------------------------------------------
    # create map
    # NOTE: for background maps check: https://leaflet-extras.github.io/leaflet-providers/preview/

    output$map <- leaflet::renderLeaflet({
        shiny::req(
            housing_type_data(),
            var_of_interest()
        )

        # retrieve needed information
        filtered_data <- housing_type_data()
        var_name <- var_of_interest()

        # retrieve values
        vals <- filtered_data[[var_name]]
        non_missing_vals <- vals[!is.na(vals)]

        # define color palette
        pal <- leaflet::colorNumeric(
            palette = "plasma",
            # domain = filtered_data[[var_name]][!is.na(filtered_data[[var_name]])],
            domain = non_missing_vals,
            na.color = "#DBDBDB"
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
                data = filtered_data
                    # NOTE: Remove this line if you want to show "No data"
                    |> dplyr::filter(!is.na(get(var_name))),
                #--------------------------------------------------
                # fill layout of the grids
                # fillColor = pal(vals),
                # USE previous line if you want to show "No data"
                fillColor = pal(non_missing_vals),
                fillOpacity = 0.9,
                popup = ~ popup_text
            ) |>
            # Overlay map labels on top
            leaflet::addProviderTiles(leaflet::providers$CartoDB.PositronOnlyLabels) |>
            # NOTE: two legends to place the "No data" legend below the coloring
            # legend. Having all in one caused the problem that for rents the
            # "no data" label appeared right to the numbers (instead of below).
            # TODO: add option to show/hide "No data" legend
            # leaflet::addLegend(
            #     position  = "bottomright",
            #     colors    = "#DBDBDB",
            #     labels    = "No data",
            #     opacity   = 0.9,
            #     title     = NULL,
            # ) |>
            leaflet::addLegend(
                position = "bottomright",
                pal = pal,
                opacity = 0.9,
                values = non_missing_vals,
                title = legend_title,
                na.label = NA
            ) |>
            #--------------------------------------------------
            # add special features (fullscreen, search, reset)
            leaflet.extras::addFullscreenControl() |>
            leaflet.extras::addSearchOSM(
                options = leaflet.extras::searchOptions(
                    zoom = 15,
                    autoCollapse = FALSE,
                    hideMarkerOnCollapse = TRUE
                )
            ) |>
            leaflet.extras::addResetMapButton()
    })

    #--------------------------------------------------
    # BUILD YOUR RENT tab
    #--------------------------------------------------

    coefficients <- reactive({
        shiny::req(
            input$selected_housing_type_builder,
            # shared characteristics across all housing types
            input$selected_endowment,
            input$selected_construction_year,
            input$selected_occupancy,
            input$selected_guestwc,
            input$selected_numrooms,
            # characteristics specific to housing type
            input$selected_elevator,
            input$selected_balcony,
            input$selected_wohngeld,
            input$selected_built_in_kitchen,
            input$selected_floor,
            input$selected_garden,
            input$selected_basement,
            input$selected_num_floors,
            input$selected_grannyflat,
            input$selected_plot_area,
            input$selected_semidetached,
            input$selected_mfh,
            input$selected_terraced,
            input$selected_exclusive,
            input$selected_detached,
            input$selected_other
        )

        # filter coefficients for housing type
        filtered_coefs_housing_type <- hedonic_model_coefs |>
            dplyr::filter(
                housing_type == input$selected_housing_type_builder
            )

        # filter for shared characteristics across all housing types
        filtered_coefs_shared <- filtered_coefs_housing_type |>
            dplyr::filter(
                (var_name == "ausstattung" & org_cat == as.integer(input$selected_endowment)) |
                (var_name == "construction_year_cat" & org_cat == as.integer(input$selected_construction_year)) |
                (var_name == "first_occupancy" & org_cat == as.integer(input$selected_occupancy)) |
                (var_name == "gaestewc" & org_cat == as.integer(input$selected_guestwc)) |
                (var_name == "zimmeranzahl_full" & org_cat == as.integer(input$selected_numrooms))
            )

        # filter for characteristics specific to housing type
        if (input$selected_housing_type_builder == "WM") {
            filtered_coefs_specific <- filtered_coefs_housing_type |>
                dplyr::filter(
                    (var_name == "balkon" & org_cat == as.integer(input$selected_balcony)) |
                    (var_name == "einbaukueche" & org_cat == as.integer(input$selected_built_in_kitchen)) |
                    (var_name == "garten" & org_cat == as.integer(input$selected_garden)) |
                    (var_name == "keller" & org_cat == as.integer(input$selected_basement))
                )
        } else if (input$selected_housing_type_builder == "WK") {
            filtered_coefs_specific <- filtered_coefs_housing_type |>
                dplyr::filter(
                    (var_name == "aufzug" & org_cat == as.integer(input$selected_elevator)) |
                    (var_name == "balkon" & org_cat == as.integer(input$selected_balcony)) |
                    (var_name == "declared_wohngeld" & org_cat == as.integer(input$selected_wohngeld)) |
                    (var_name == "einbaukueche" & org_cat == as.integer(input$selected_built_in_kitchen)) |
                    (var_name == "floors_cat" & org_cat == as.integer(input$selected_floor)) |
                    (var_name == "garten" & org_cat == as.integer(input$selected_garden)) |
                    (var_name == "keller" & org_cat == as.integer(input$selected_basement)) |
                    (var_name == "num_floors_cat" & org_cat == as.integer(input$selected_num_floors))
                )
        } else {
            filtered_coefs_specific <- filtered_coefs_housing_type |>
                dplyr::filter(
                    (var_name == "einliegerwohnung" & org_cat == as.integer(input$selected_grannyflat)) |
                    (var_name == "plot_area_cat" & org_cat == as.integer(input$selected_plot_area)) |
                    (var_name == "typ_DHH" & org_cat == as.integer(input$selected_semidetached)) |
                    (var_name == "typ_MFH" & org_cat == as.integer(input$selected_mfh)) |
                    (var_name == "typ_Reihenhaus" & org_cat == as.integer(input$selected_terraced)) |
                    (var_name == "typ_exclusive" & org_cat == as.integer(input$selected_exclusive)) |
                    (var_name == "typ_freistehend" & org_cat == as.integer(input$selected_detached)) |
                    (var_name == "typ_other" & org_cat == as.integer(input$selected_other))
                )
        }

        # combine both dataframes
        filtered_coefs <- rbind(
            filtered_coefs_shared,
            filtered_coefs_specific
        )

        # return
        filtered_coefs
    })

    output$coefficients <- renderTable({coefficients()})


}