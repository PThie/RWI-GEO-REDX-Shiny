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

        # define columns
        vi  <- var_of_interest()
        vd  <- var_deviation()
        vdp <- var_deviation_perc()

        cols <- c("grid", "housing_type", "city_name", vi, vd, vdp, "geometry")

        # filter data to selection
        filtered <- redx_data[
            housing_type == input$selected_housing_type,
            ..cols
        ]

        # add legend output
        filtered[, price_fmt :=
            fifelse(
                is.na(get(vi)),
                "No data",
                paste0(
                    scales::comma(
                        round(get(vi), 2),
                        accuracy = 0.01
                    ),
                    " &euro;/m&sup2;"
                )
            )
        ]


        filtered[, dev_fmt :=
            fifelse(
                is.na(get(vd)),
                "No data",
                paste0(
                    scales::comma(
                        round(get(vd), 2),
                        accuracy = 0.01
                    ),
                    " &euro;/m&sup2; (",
                    scales::comma(round(get(vdp), 2), accuracy = 0.01),
                    "%)"
                )
            )
        ]

        # add price label for popup
        filtered[, price_label := price_label]

        # create popup text
        filtered[, popup_text :=
            paste0(
            "<div style='width:250px; font-family:Calibri, sans-serif;'>",
                "<p style='font-size:100%; color:grey; margin:0;'>Grid in:</p>",
                "<p style='font-size:140%; margin:0;'>", city_name, "</p>",
            "</div>",
            "<hr style='margin:4px 0;'/>",
            "<div style='width:250px; font-family:Calibri, sans-serif;'>",
                "<p style='font-size:100%; color:grey; margin:0;'>", price_label, "</p>",
                "<p style='font-size:140%; margin:0;'>", price_fmt, "</p>",
            "</div>",
            "<div style='width:250px; font-family:Calibri, sans-serif;'>",
                "<p style='font-size:100%; color:grey; margin:0;'>Change rel. to German average:</p>",
                "<p style='font-size:140%; margin:0;'>", dev_fmt, "</p>",
            "</div>"
            )
        ]

        # remove grids with no data for this years
        # NOTE: Remove this line if you want to show "No data"
        filtered <- filtered[!is.na(get(vi))]

        filtered
    }) |> shiny::bindCache(
        input$selected_housing_type,
        input$selected_year
    )

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
        filtered_data <- sf::st_set_geometry(
            filtered_data,
            "geometry"
        )
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
            input$selected_housing_type_builder
        )

        # filter coefficients for housing type
        filtered_coefs_housing_type <- hedonic_model_coefs |>
            dplyr::filter(
                housing_type == input$selected_housing_type_builder
            )

        # filter for characteristics
        if (input$selected_housing_type_builder == "WM") {
            shiny::req(
                # shared characteristics across all housing types
                input$selected_endowment_WM,
                input$selected_construction_year_WM,
                input$selected_occupancy_WM,
                input$selected_guestwc_WM,
                input$selected_numrooms_WM,
                # characteristics specific to housing type
                input$selected_balcony_WM,
                input$selected_built_in_kitchen_WM,
                input$selected_garden_WM,
                input$selected_basement_WM
            )

            filtered_coefs <- filtered_coefs_housing_type |>
                dplyr::filter(
                    # shared characteristics
                    (var_name == "ausstattung" & org_cat == as.integer(input$selected_endowment_WM)) |
                    (var_name == "construction_year_cat" & org_cat == as.integer(input$selected_construction_year_WM)) |
                    (var_name == "first_occupancy" & org_cat == as.integer(input$selected_occupancy_WM)) |
                    (var_name == "gaestewc" & org_cat == as.integer(input$selected_guestwc_WM)) |
                    (var_name == "zimmeranzahl_full" & org_cat == as.integer(input$selected_numrooms_WM)) |
                    # specific characteristics
                    (var_name == "balkon" & org_cat == as.integer(input$selected_balcony_WM)) |
                    (var_name == "einbaukueche" & org_cat == as.integer(input$selected_built_in_kitchen_WM)) |
                    (var_name == "garten" & org_cat == as.integer(input$selected_garden_WM)) |
                    (var_name == "keller" & org_cat == as.integer(input$selected_basement_WM))
                )
        } else if (input$selected_housing_type_builder == "WK") {
                shiny::req(
                    # shared characteristics across all housing types
                    input$selected_endowment_WK,
                    input$selected_construction_year_WK,
                    input$selected_occupancy_WK,
                    input$selected_guestwc_WK,
                    input$selected_numrooms_WK,
                    # characteristics specific to housing type
                    input$selected_elevator_WK,
                    input$selected_balcony_WK,
                    input$selected_wohngeld_WK,
                    input$selected_built_in_kitchen_WK,
                    input$selected_floor_WK,
                    input$selected_garden_WK,
                    input$selected_basement_WK,
                    input$selected_num_floors_WK
                )

            filtered_coefs <- filtered_coefs_housing_type |>
                dplyr::filter(
                    # shared characteristics
                    (var_name == "ausstattung" & org_cat == as.integer(input$selected_endowment_WK)) |
                    (var_name == "construction_year_cat" & org_cat == as.integer(input$selected_construction_year_WK)) |
                    (var_name == "first_occupancy" & org_cat == as.integer(input$selected_occupancy_WK)) |
                    (var_name == "gaestewc" & org_cat == as.integer(input$selected_guestwc_WK)) |
                    (var_name == "zimmeranzahl_full" & org_cat == as.integer(input$selected_numrooms_WK)) |
                    # specific characteristics
                    (var_name == "aufzug" & org_cat == as.integer(input$selected_elevator_WK)) |
                    (var_name == "balkon" & org_cat == as.integer(input$selected_balcony_WK)) |
                    (var_name == "declared_wohngeld" & org_cat == as.integer(input$selected_wohngeld_WK)) |
                    (var_name == "einbaukueche" & org_cat == as.integer(input$selected_built_in_kitchen_WK)) |
                    (var_name == "floors_cat" & org_cat == as.integer(input$selected_floor_WK)) |
                    (var_name == "garten" & org_cat == as.integer(input$selected_garden_WK)) |
                    (var_name == "keller" & org_cat == as.integer(input$selected_basement_WK)) |
                    (var_name == "num_floors_cat" & org_cat == as.integer(input$selected_num_floors_WK))
                )
        } else {
            shiny::req(
                # shared characteristics across all housing types
                input$selected_endowment_HK,
                input$selected_construction_year_HK,
                input$selected_occupancy_HK,
                input$selected_guestwc_HK,
                input$selected_numrooms_HK,
                # characteristics specific to housing type
                input$selected_grannyflat_HK,
                input$selected_plot_area_HK,
                input$selected_semidetached_HK,
                input$selected_mfh_HK,
                input$selected_terraced_HK,
                input$selected_exclusive_HK,
                input$selected_detached_HK,
                input$selected_other_HK
            )
            
            filtered_coefs <- filtered_coefs_housing_type |>
                dplyr::filter(
                    # shared characteristics
                    (var_name == "ausstattung" & org_cat == as.integer(input$selected_endowment_HK)) |
                    (var_name == "construction_year_cat" & org_cat == as.integer(input$selected_construction_year_HK)) |
                    (var_name == "first_occupancy" & org_cat == as.integer(input$selected_occupancy_HK)) |
                    (var_name == "gaestewc" & org_cat == as.integer(input$selected_guestwc_HK)) |
                    (var_name == "zimmeranzahl_full" & org_cat == as.integer(input$selected_numrooms_HK)) |
                    # specific characteristics
                    (var_name == "einliegerwohnung" & org_cat == as.integer(input$selected_grannyflat_HK)) |
                    (var_name == "plot_area_cat" & org_cat == as.integer(input$selected_plot_area_HK)) |
                    (var_name == "typ_DHH" & org_cat == as.integer(input$selected_semidetached_HK)) |
                    (var_name == "typ_MFH" & org_cat == as.integer(input$selected_mfh_HK)) |
                    (var_name == "typ_Reihenhaus" & org_cat == as.integer(input$selected_terraced_HK)) |
                    (var_name == "typ_exclusive" & org_cat == as.integer(input$selected_exclusive_HK)) |
                    (var_name == "typ_freistehend" & org_cat == as.integer(input$selected_detached_HK)) |
                    (var_name == "typ_other" & org_cat == as.integer(input$selected_other_HK))
                )
        }

        # return
        filtered_coefs
    })

    output$coefficients <- renderTable({coefficients()})

    # sum up coefficients to total effect
    total_effect <- reactive({
        shiny::req(
            coefficients(),
            input$selected_housing_type_builder
        )

        # get filtered coefficient
        coefs <- coefficients()

        # get smearing factor for housing type
        smearing_factor_housing_type <- smearing_factors |>
            dplyr::filter(
                housing_type == input$selected_housing_type_builder
            ) |>
            dplyr::pull(smearing_factor)

        # calculate total effect
        total_effect <- exp(sum(coefs$estimate)) * smearing_factor_housing_type

        total_effect
    })

    output$total_effect <- renderText({
        shiny::req(total_effect())

        paste0(
            "Estimated ",
            ifelse(
                input$selected_housing_type_builder == "WM",
                "rent",
                "price"
            ),
            ": ",
            scales::comma(
                round(total_effect(), 2),
                accuracy = 0.01
            ),
            " \U20AC/m\u00B2"
        )
    })


}