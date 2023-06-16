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
            menuItem("Migrations",
                tabName = "migrations",
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
                        title = "Année du recensement",
                        value = withSpinner(
                            textOutput("annee_recensement"),
                            type = 7,
                            size = .4,
                            proxy.height = 57.6
                        ),
                        icon = icon("calendar"),
                        color = "indigo"
                    ),
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
                        title = "Âge médian",
                        value = withSpinner(
                            textOutput("age_median"),
                            type = 7,
                            size = .4,
                            proxy.height = 57.6
                        ),
                        icon = icon("child-reaching"),
                        color = "maroon"
                    ),
                    infoBox(
                        title = "Salaire mensuel moyen",
                        value = withSpinner(
                            textOutput("wpm_moyen"),
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
                    tags$h1("Démographie")
                ),
                fluidRow(
                    tags$br()
                ),
                fluidRow(
                    box(
                        title = "Pyramide des âges",
                        withSpinner(
                            plotlyOutput("ages_pyramid"),
                            type = 8
                        ),
                        tags$br(),
                        awesomeCheckboxGroup(
                            inputId = "demog_race_selector",
                            label = "Ethnies sélectionnées :",
                            choices = c("White", "Black", "Natives", "Asian/Pacific", "Hispanic/Latino"),
                            selected = c("White", "Black", "Natives", "Asian/Pacific", "Hispanic/Latino")
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
                                    icon = icon("flag"),
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
                                    icon = icon("sort"),
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
                    tags$h1("Revenu")
                ),
                fluidRow(
                    tags$br()
                ),
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
                            inputId = "rev_selected_age",
                            label = "Tranche d'âge : ",
                            min = 0,
                            max = 90,
                            value = c(0, 90),
                            ticks = FALSE
                        )
                    )
                )
            ),
            tabItem(
                tabName = "emploi",
                fluidRow(
                    tags$h1("Emploi")
                ),
                fluidRow(
                    tags$br()
                ),
                fluidRow(
                    box(
                        status = "primary",
                        width = 12,
                        sliderInput(
                            inputId = "employ_selected_age",
                            label = "Tranche d'âge : ",
                            min = 0,
                            max = 90,
                            value = c(0, 90),
                            ticks = FALSE
                        )
                    )
                ),
                fluidRow(
                    box(
                        title = "Taux d'emploi des interrogés, par ethnie ou par genre",
                        withSpinner(
                            plotlyOutput("employment_rate"),
                            type = 8
                        )
                    ),
                    box(
                        title = "Nombre de semaines travaillées par an, par ethnie ou par genre",
                        withSpinner(
                            plotlyOutput("weeks_worked"),
                            type = 8
                        )
                    )
                ),
                fluidRow(
                    box(
                        status = "primary",
                        title = "Industries ou occupations par genre ou ethnie",
                        width = 12,
                        withSpinner(
                            plotlyOutput("industry_occupation", height = "500px"),
                            type = 8
                        ),
                        tags$br(),
                        fluidRow(
                            column(
                                width = 3,
                                prettyRadioButtons(
                                    inputId = "employ_selected_industry_occupation",
                                    label = "Données : ",
                                    choices = c("Industrie", "Occupation"),
                                    icon = icon("file"),
                                    animation = "tada",
                                    inline = TRUE
                                )
                            ),
                            column(
                                width = 3,
                                prettyRadioButtons(
                                    inputId = "employ_selected_filter",
                                    label = "Filtre : ",
                                    choices = c("Ethnie", "Genre"),
                                    icon = icon("filter"),
                                    animation = "tada",
                                    inline = TRUE
                                )
                            ),
                            column(
                                width = 3,
                                prettyRadioButtons(
                                    inputId = "employ_industry_occupation_order",
                                    label = "Ordre : ",
                                    choices = c("Croissant", "Décroissant"),
                                    icon = icon("sort"),
                                    animation = "tada",
                                    inline = TRUE
                                )
                            )
                        )
                    )
                )
            ),
            tabItem(
                tabName = "education",
                fluidRow(
                    tags$h1("Éducation")
                ),
                fluidRow(
                    tags$br()
                )
            ),
            tabItem(
                tabName = "migrations",
                fluidRow(
                    tags$h1("Migrations")
                ),
                fluidRow(
                    tags$br()
                ),
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
