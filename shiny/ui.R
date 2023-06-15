library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(bs4Dash)
library(shinyWidgets)
library(shinycssloaders)
library(plotly)
library(threejs)

dashboardPage(
    dark = TRUE,
    scrollToTop = TRUE,
    dashboardHeader(
        title = "Census Income Dashboard",
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
        tags$link(rel = "icon", type = "image/png", href = "favicon.png")
    ),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Statistiques",
                tabName = "stats",
                icon = icon("arrow-trend-up")
            ),
            menuItem("Démographie",
                tabName = "demographie",
                icon = icon("address-card")
            ),
            menuItem("Revenu",
                tabName = "revenu",
                icon = icon("dollar-sign")
            ),
            menuItem("Emploi",
                tabName = "emploi",
                icon = icon("briefcase")
            ),
            menuItem("Éducation",
                tabName = "education",
                icon = icon("graduation-cap")
            ),
            menuItem("Cartes",
                tabName = "cartes",
                icon = icon("globe-americas")
            ),
            menuItem("À propos",
                tabName = "apropos",
                icon = icon("circle-question")
            )
        )
    ),
    dashboardBody(
        chooseSliderSkin("Round"),
        tabItems(
            tabItem(
                tabName = "stats",
                fluidRow(
                    tags$h1("Statistiques")
                ),
                fluidRow(
                    tags$br()
                ),
                fluidRow(
                    infoBox(
                        title = "Observations",
                        value = withSpinner(
                            textOutput("nb_observations"),
                            type = 7,
                            size = .4,
                            proxy.height = 57.6
                        ),
                        icon = icon("users"),
                        color = "purple"
                    ),
                    infoBox(
                        title = "Dimensions",
                        value = withSpinner(
                            textOutput("nb_dimensions"),
                            type = 7,
                            size = .4,
                            proxy.height = 57.6
                        ),
                        icon = icon("cubes"),
                        color = "lightblue"
                    ),
                    infoBox(
                        title = "Âge moyen",
                        value = withSpinner(
                            textOutput("age_moyen"),
                            type = 7,
                            size = .4,
                            proxy.height = 57.6
                        ),
                        icon = icon("person-cane"),
                        color = "lime"
                    ),
                    infoBox(
                        title = "Salaire horaire moyen",
                        value = withSpinner(
                            textOutput("wph_moyen"),
                            type = 7,
                            size = .4,
                            proxy.height = 57.6
                        ),
                        icon = icon("dollar-sign"),
                        color = "orange"
                    )
                )
            ),
            tabItem(
                tabName = "demographie",
                fluidRow(
                    box(
                        title = "Pyramide des âges",
                        withSpinner(
                            plotlyOutput("ages_pyramid"),
                            type = 8
                        ),
                        tags$br(),
                        prettyRadioButtons(
                            inputId = "demog_race_selector",
                            label = "Ethnie :",
                            choices = c("Toutes", "White", "Black", "Natives", "Asian/Pacific", "Other"),
                            icon = icon("user"),
                            animation = "tada"
                        )
                    ),
                    box(
                        title = "Distribution des genres et des ethnies",
                        withSpinner(
                            plotlyOutput("race_sex_distribution"),
                            type = 8
                        ),
                        tags$br(),
                        prettyRadioButtons(
                            inputId = "demog_format_selector",
                            label = "Format :",
                            choices = c("Nombre", "Pourcentage"),
                            icon = icon("filter"),
                            animation = "tada",
                            inline = TRUE
                        )
                    ),
                    box(
                        title = "Pays de naissance des interrogés",
                        withSpinner(
                            plotlyOutput("birth_country", height = "600px"),
                            type = 8
                        ),
                        tags$br(),
                        fluidRow(
                            column(
                                width = 6,
                                prettyRadioButtons(
                                    inputId = "demog_country_selector",
                                    label = "Pays à afficher : ",
                                    choices = c("Tous", "Hors USA"),
                                    icon = icon("filter"),
                                    animation = "tada",
                                    inline = TRUE
                                )
                            ),
                            column(
                                width = 6,
                                prettyRadioButtons(
                                    inputId = "demog_country_order",
                                    label = "Ordre : ",
                                    choices = c("Croissant", "Décroissant"),
                                    icon = icon("sort-amount-up"),
                                    animation = "tada",
                                    inline = TRUE
                                )
                            )
                        )
                    )
                )
            ),
            tabItem(
                tabName = "revenu",
                fluidRow(
                    box(
                        title = "Niveau de revenu par ethnie et genre",
                        withSpinner(
                            plotlyOutput("race_income", height = "500px"),
                            type = 8
                        ),
                        tags$br(),
                        awesomeCheckboxGroup(
                            inputId = "rev_selected_race",
                            label = "Ethnies sélectionnées :",
                            choices = c("White", "Black", "Natives", "Asian/Pacific", "Hispanic/Latino"),
                            selected = c("White", "Black", "Natives", "Asian/Pacific", "Hispanic/Latino")
                        )
                    ),
                    box(
                        title = "Salaire mensuel moyen par ethnie ou par genre",
                        withSpinner(
                            plotlyOutput("wage_per_month", height = "500px"),
                            type = 8
                        ),
                        tags$br(),
                        prettyRadioButtons(
                            inputId = "rev_selected_filter",
                            label = "Filtre : ",
                            choices = c("Ethnie", "Genre"),
                            icon = icon("filter"),
                            animation = "tada",
                            inline = TRUE
                        ),
                        sliderInput(
                            inputId = "rev_selected_max_age",
                            label = "Âge : ",
                            min = 0,
                            max = 90,
                            value = c(0, 90),
                            ticks = FALSE
                        )
                    )
                )
            ),
            tabItem(
                tabName = "cartes",
                fluidRow(
                    box(
                        title = "Le melting-pot américain : visualisation des origines internationales
                        des résidents actuels aux États-Unis à l'aide d'un globe terrestre",
                        withSpinner(
                            globeOutput("globe"),
                            type = 8
                        )
                    ),
                    box(
                        title = "Cartographie des migrations internes aux États-Unis :
                        les États d'origine des populations interrogées",
                        withSpinner(
                            plotlyOutput("state_map"),
                            type = 8
                        )
                    )
                )
            )
        )
    ),
    dashboardControlbar(
        skinSelector()
    )
)
