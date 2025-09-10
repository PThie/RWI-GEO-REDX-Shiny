#--------------------------------------------------
# start front end

ui <- shiny::navbarPage(
    title = "RWI-GEO-REDX",
    id = "navbar",
    theme = bslib::bs_theme(
        version = 5,
        bootswatch = "lumen",
        base_font = bslib::font_google("Roboto"),
        code_font = bslib::font_google("Fira Code")
    ),
    #--------------------------------------------------
    # INTERACTIVE MAP tab
    #--------------------------------------------------
    shiny::tabPanel(
        title = "Interactive Map",
        tags$head(
            shiny::includeCSS("www/styles.css")    
        ),
        div(
            class = "outer",
            leaflet::leafletOutput("map", height = "100%", width = "100%"),
            shiny::absolutePanel(
                id = "options-map",
                class = "panel panel-default", 
                fixed = TRUE,
                draggable = TRUE,
                top = 80,
                left = "auto",
                right = 20,
                bottom = "auto",
                width = 340,
                height = "auto",
                h2("Map - Options"),
                selectInput(
                    inputId = "selected_housing_type",
                    label = "Select housing type:",
                    choices = list(
                        "House sales" = "HK",
                        "Apartment sales" = "WK",
                        "Apartment rents" = "WM"
                    ),
                    # set default value
                    selected = "WM"
                ),
                selectInput(
                    inputId = "selected_year",
                    label = "Select year:",
                    choices = seq(2008, config_globals()[["max_year"]], by = 1),
                    # set default value
                    selected = config_globals()[["max_year"]]
                )
            )
        ),
        #--------------------------------------------------
        # Citation data source
        div(
            id = "cite",
            "Data source: RWI-GEO-REDX",
            tags$a(
                "(RWI Real Estate Data)",
                href = "https://www.rwi-essen.de/en/research-advice/further/research-data-center-ruhr-fdz/data-sets/rwi-geo-red/x-real-estate-data-and-price-indices",
                target = "_blank",
                rel = "noopener noreferrer"
            ),
            #--------------------------------------------------
            # info button
            shiny::actionButton(
                inputId = "btn_pop",
                label = NULL,
                icon = shiny::icon("circle-info"),
                style = "padding:16px; font-size:80%; background-color:transparent; border-color:transparent;",
                class = "btn-info"
            ) |>
            bslib::popover(
                title = "Quick info on RWI-GEO-REDX",
                paste0(
                    "The FDZ Ruhr at RWI provides regional price indices for apartments",
                    " and houses (rentals and sales) in Germany since 2008 through",
                    " the RWI-GEO-REDX dataset, based on property listings from",
                    " ImmoScout24 (RWI-GEO-RED). RWI-GEO-REDX stands out for its",
                    " high spatial resolution: the exact location of each listing",
                    " allows price indices to be calculated at the level of 1×1 km",
                    " grid cells. Results are aggregated at regional levels including",
                    " grid cells, municipalities, counties, and labor market regions.",
                    " The indices are reported as quality-adjusted absolute prices,",
                    " including annual and regional changes. A key feature is the",
                    " location-adjusted national index, which accounts for shifts",
                    " in the regional composition of listings over time."
                )
            )
        )
    ),
    #--------------------------------------------------
    # BUILD YOUR RENT tab
    #--------------------------------------------------
    # TODO: Inputs need to change according to model/ housing type
    shiny::tabPanel(
        title = "Build Your Rent",
        div(
            class = "builderOptions",
            tags$head(
                shiny::includeCSS("www/styles.css")
            ),
            h3("Select housing type"),
            selectInput(
                inputId = "selected_housing_type_builder",
                label = "",
                choices = list(
                    "House sales" = "HK",
                    "Apartment sales" = "WK",
                    "Apartment rents" = "WM"
                ),
                # set default value
                selected = "WM"
            ),
            h3("Input your factors and calculate your rent/price"),
            bslib::accordion(
                id = "collapseAttributes",
                #--------------------------------------------------
                # Panel for primary characteristics
                #--------------------------------------------------
                bslib::accordion_panel(
                    title = "Primary Housing Characteristics",
                    #--------------------------------------------------
                    # Primary characteristics for WK
                    #--------------------------------------------------
                    shiny::conditionalPanel(
                        condition = "input.selected_housing_type_builder == 'WK'",
                        bslib::layout_columns(
                            selectInput(
                                inputId = "selected_construction_year_WK",
                                label = shiny::HTML("<b>Construction year (category):</b>"),
                                choices = list(
                                    # NOTE: 1 is reference category
                                    "Before 1900" = "2",
                                    "1900-1944" = "3",
                                    "1945-1959" = "4",
                                    "1960-1969" = "5",
                                    "1970-1979" = "6",
                                    "1980-1989" = "7",
                                    "1990-1999" = "8",
                                    "2000-2009" = "9",
                                    "2010 and later" = "10"
                                ),
                                selected = "10"
                            ),
                            selectInput(
                                inputId = "selected_endowment_WK",
                                label = shiny::HTML("<b>Endowment (category):</b>"),
                                choices = list(
                                    "Simple" = "1",
                                    "Normal" = "2",
                                    "Sophisticated" = "3",
                                    "Deluxe" = "4"
                                ),
                                selected = "2"
                            )
                        ),
                        bslib::layout_columns(
                            sliderInput(
                                inputId = "selected_numrooms_WK",
                                label = shiny::HTML("<b>Number of rooms:</b>"),
                                min = 1,
                                max = 8,
                                value = 3
                            ),
                            selectInput(
                                inputId = "selected_floor_WK",
                                label = shiny::HTML("<b>Floor (category):</b>"),
                                choices = list(
                                    "Groundfloor" = "1",
                                    "1st floor" = "2",
                                    "2nd to 3rd floor" = "3",
                                    "4th to 5th floor" = "4",
                                    "6th to 10th floor" = "5"
                                    # NOTE: Currently not in estimation (might change)
                                    # "11th floor or higher" = "6"
                                )
                            )
                        )
                    ),
                    #--------------------------------------------------
                    # Primary characteristics for HK
                    #--------------------------------------------------
                    shiny::conditionalPanel(
                        condition = "input.selected_housing_type_builder == 'HK'",
                        bslib::layout_columns(
                            selectInput(
                                inputId = "selected_construction_year_HK",
                                label = shiny::HTML("<b>Construction year (category):</b>"),
                                choices = list(
                                    # NOTE: 1 is reference category
                                    "Before 1900" = "2",
                                    "1900-1944" = "3",
                                    "1945-1959" = "4",
                                    "1960-1969" = "5",
                                    "1970-1979" = "6",
                                    "1980-1989" = "7",
                                    "1990-1999" = "8",
                                    "2000-2009" = "9",
                                    "2010 and later" = "10"
                                ),
                                selected = "10"
                            )
                        )
                    )
                ),
                #--------------------------------------------------
                # Panel for secondary characteristics
                #--------------------------------------------------
                bslib::accordion_panel(
                    title = "Secondary Housing Characteristics",
                    shiny::conditionalPanel(
                        condition = "input.selected_housing_type_builder == 'WK'",
                        bslib::layout_columns(
                            radioButtons(
                                inputId = "selected_occupancy_WK",
                                label = shiny::HTML("<b>First occupancy?</b>"),
                                choices = list(
                                    "Yes" = "1",
                                    "No" = "0"
                                ),
                                selected = "0"
                            ),
                            radioButtons(
                                inputId = "selected_guestwc_WK",
                                label = shiny::HTML("<b>Guest Bathroom?</b>"),
                                choices = list(
                                    "Yes" = "1",
                                    "No" = "0"
                                ),
                                selected = "0"
                            ),
                            radioButtons(
                                inputId = "selected_elevator_WK",
                                label = shiny::HTML("<b>Elevator?</b>"),
                                choices = list(
                                    "Yes" = "1",
                                    "No" = "0"
                                ),
                                selected = "0"
                            )
                        ),
                        bslib::layout_columns(
                            radioButtons(
                                inputId = "selected_balcony_WK",
                                label = shiny::HTML("<b>Balcony?</b>"),
                                choices = list(
                                    "Yes" = "1",
                                    "No" = "0"
                                ),
                                selected = "0"
                            ),
                            radioButtons(
                                inputId = "selected_garden_WK",
                                label = shiny::HTML("<b>Garden?</b>"),
                                choices = list(
                                    "Yes" = "1",
                                    "No" = "0"
                                ),
                                selected = "0"
                            ),
                            radioButtons(
                                inputId = "selected_basement_WK",
                                label = shiny::HTML("<b>Basement?</b>"),
                                choices = list(
                                    "Yes" = "1",
                                    "No" = "0"
                                ),
                                selected = "0"
                            )
                        ),
                        bslib::layout_columns(
                            radioButtons(
                                inputId = "selected_wohngeld_wk",
                                label = shiny::HTML("<b>Eligible for housing allowance (Wohngeld)?</b>"),
                                choices = list(
                                    "Yes" = "1",
                                    "No" = "0"
                                ),
                                selected = "0"
                            ),
                            radioButtons(
                                inputId = "selected_built_in_kitchen_WK",
                                label = shiny::HTML("<b>Built-in kitchen?</b>"),
                                choices = list(
                                    "Yes" = "1",
                                    "No" = "0"
                                ),
                                selected = "0"
                            ),
                            selectInput(
                                inputId = "selected_num_floors_WK",
                                label = shiny::HTML("<b>Total number of floors (category):</b>"),
                                choices = list(
                                    "1-3 floors" = "2",
                                    "4-5 floors" = "3",
                                    "6-10 floors" = "4",
                                    "More than 10 floors" = "5"
                                ),
                                selected = "2"
                            )
                        )
                    )
                )
            )
        )
    )
)


                            # radioButtons(
                            #     inputId = "selected_grannyflat_WK",
                            #     label = "Granny flat?",
                            #     choices = list(
                            #         "Yes" = "1",
                            #         "No" = "0"
                            #     ),
                            #     selected = "0"
                            # ),

# radioButtons(
#                             inputId = "selected_detached",
#                             label = "Detached house?",
#                             choices = list(
#                                 "Yes" = "yes",
#                                 "No" = "no"
#                             ),
#                             selected = "no"
#                         ),
#                         radioButtons(
#                             inputId = "selected_semidetached",
#                             label = "Semi-detached house?",
#                             choices = list(
#                                 "Yes" = "yes",
#                                 "No" = "no"
#                             ),
#                             selected = "no"
#                         ),
#                         radioButtons(
#                             inputId = "selected_terraced",
#                             label = "Terraced house?",
#                             choices = list(
#                                 "Yes" = "yes",
#                                 "No" = "no"
#                             ),
#                             selected = "no"
#                         ),
#                         # TODO: check what type this is
#                         radioButtons(
#                             inputId = "selected_exclusive",
#                             label = "Exclusive house?",
#                             choices = list(
#                                 "Yes" = "yes",
#                                 "No" = "no"
#                             ),
#                             selected = "no"
#                         ),
#                         radioButtons(
#                             inputId = "selected_mfh",
#                             label = "Multi-family house?",
#                             choices = list(
#                                 "Yes" = "yes",
#                                 "No" = "no"
#                             ),
#                             selected = "no"
#                         ),
#                         radioButtons(
#                             inputId = "selected_other",
#                             label = "Other?",
#                             choices = list(
#                                 "Yes" = "yes",
#                                 "No" = "no"
#                             ),
#                             selected = "no"
#                         )