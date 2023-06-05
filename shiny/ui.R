library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(bs4Dash)
library(shinycssloaders)
library(plotly)
library(threejs)

dashboardPage(
    dark = TRUE,
    dashboardHeader(
        title = "Census Income",
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
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
        tabItems(
            tabItem(
                tabName = "stats",
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
                tabName = "cartes",
                fluidRow(
                    box(
                        title = "Le melting-pot américain :
                            Visualisation des origines internationales des résidents actuels aux États-Unis",
                        withSpinner(
                            globeOutput("globe"),
                            type = 8
                        )
                    ),
                    box(
                        title = "Cartographie des migrations internes aux États-Unis :
                        les origines des résidents actuels par État de départ",
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
