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
            menuItem("Présentation",
                tabName = "presentation",
                icon = icon("chalkboard")
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
                tabName = "presentation",
                fluidRow(
                    tags$h1("Présentation")
                ),
                fluidRow(
                    tags$br()
                ),
                fluidRow(
                    box(
                        width = 12,
                        status = "primary",
                        title = "Dashboard interactif : exploration du dataset Census Income",
                        tags$div(
                            "Ce dataset, extrait d'un recensement américain, se concentre principalement sur les données démographiques et l'emploi des individus.
                        L'objectif initial de ce jeu de données était le Machine Learning : entraîner une intelligence artificielle à prédire si un individu gagne
                        plus ou moins de 50 000 dollars par an, à partir de toutes les autres dimensions du dataset. Il est disponible sur le site de l'", tags$a(href = "https://archive.ics.uci.edu/dataset/117/census+income+kdd", "UCI Machine Learning Repository."),
                            tags$br(),
                            "Ce dashboard a pour but de présenter notre exploration de manière interactive : des composants graphiques vous permettent de filtrer les données selon vos préférences
                        et la librarie Plotly vous permet de zoomer et de vous déplacer dans les graphiques. Pour plus d'informations, voir la section \"À propos\"."
                        )
                    )
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
                        color = "navy"
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
                        status = "secondary",
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
                        status = "secondary",
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
                        status = "secondary",
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
                        status = "secondary",
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
                        status = "secondary",
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
                        column(
                            width = 12,
                            sliderInput(
                                inputId = "employ_selected_age",
                                label = "Tranche d'âge : ",
                                min = 0,
                                max = 90,
                                value = c(0, 90),
                                ticks = FALSE
                            )
                        ),
                        column(
                            width = 6,
                            prettyRadioButtons(
                                inputId = "employ_selected_race_sex",
                                label = "Filtre : ",
                                choices = c("Ethnie", "Genre"),
                                icon = icon("filter"),
                                animation = "tada",
                                inline = TRUE
                            )
                        )
                    )
                ),
                fluidRow(
                    box(
                        status = "secondary",
                        title = "Taux d'emploi des interrogés, par ethnie ou par genre",
                        withSpinner(
                            plotlyOutput("employment_rate"),
                            type = 8
                        )
                    ),
                    box(
                        status = "secondary",
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
                        title = "Industries ou secteurs par genre ou ethnie",
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
                                    choices = c("Industries", "Secteurs"),
                                    icon = icon("file"),
                                    animation = "tada",
                                    inline = TRUE
                                )
                            ),
                            column(
                                width = 3,
                                prettyRadioButtons(
                                    inputId = "employ_selected_industry_occupation_filter",
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
                ),
                fluidRow(
                    box(
                        width = 12,
                        status = "secondary",
                        title = "Salaire mensuel moyen par niveau d'éducation",
                        withSpinner(
                            plotlyOutput("wage_education"),
                            type = 8
                        )
                    ),
                    box(
                        width = 12,
                        status = "secondary",
                        title = "Niveau d'étude en fonction de l'ethnie ou du genre",
                        withSpinner(
                            plotlyOutput("wage_race_sex"),
                            type = 8
                        ),
                        tags$br(),
                        prettyRadioButtons(
                            inputId = "edu_selected_filter",
                            label = "Filtre : ",
                            choices = c("Ethnie", "Genre"),
                            icon = icon("filter"),
                            animation = "tada",
                            inline = TRUE
                        )
                    ),
                    box(
                        width = 12,
                        status = "secondary",
                        title = "Niveau d'étude en fonction du domaine d'industrie ou du secteur",
                        withSpinner(
                            plotlyOutput("education_domain", height = "500px"),
                            type = 8
                        ),
                        tags$br(),
                        prettyRadioButtons(
                            inputId = "edu_selected_domain",
                            label = "Données : ",
                            choices = c("Industries", "Secteurs"),
                            icon = icon("file"),
                            animation = "tada",
                            inline = TRUE
                        )
                    )
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
                        status = "secondary",
                        title = "Le melting-pot américain : visualisation des origines internationales
                        des résidents actuels aux États-Unis à l'aide d'un globe terrestre",
                        withSpinner(
                            globeOutput("globe"),
                            type = 8
                        )
                    ),
                    box(
                        status = "secondary",
                        title = "Cartographie des migrations internes aux États-Unis :
                        les États d'origine des populations interrogées (passer la souris sur les États pour plus d'informations)",
                        withSpinner(
                            plotlyOutput("state_map"),
                            type = 8
                        )
                    )
                )
            ),
            tabItem(
                tabName = "apropos",
                fluidRow(
                    tags$h1("À propos du dashboard")
                ),
                fluidRow(
                    tags$br()
                ),
                fluidRow(
                    box(
                        width = 8,
                        status = "primary",
                        title = "Pourquoi ce dashboard ?",
                        tags$div(
                            "Ce dashboard a été réalisé dans le cadre de l'UE IF36 à l'", tags$a(href = "https://www.utt.fr/", "Université de Technologie de Troyes"), ".
                            Il a pour but de présenter les résultats de notre exploration de données sur le jeu de données de notre choix, en complément d'un rapport et d'une soutenance orale."
                        )
                    ),
                    box(
                        width = 8,
                        status = "secondary",
                        title = "Comment ?",
                        tags$div(
                            "Grâce au langage R, le dashboard a été développé avec les libraries Shiny, ShinyDashboard(Plus), Intro.js,
                            et bien d'autres pour la mise en forme et la visualisation des données (notamment Three.js pour le globe terrestre)."
                        )
                    ),
                    box(
                        width = 8,
                        status = "secondary",
                        title = "Par qui ?",
                        tags$div(
                            tags$b("Clara Gullotta, Julien Crabos et Tanguy Hardion"), ", étudiants en 1ère année de cycle ingénieur à l'UTT en Informatique et Systèmes d'Information."
                        )
                    ),
                )
            )
        )
    ),
    dashboardControlbar(
        skinSelector()
    )
)
