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
                        "Observations",
                        value = withSpinner(
                            textOutput("nb_observations"),
                            type = 6,
                            size = .3,
                            proxy.height = 57.6
                        ),
                        icon = icon("users"),
                        color = "purple"
                    ),
                    infoBox(
                        "Dimensions",
                        value = withSpinner(
                            textOutput("nb_dimensions"),
                            type = 6,
                            size = .3,
                            proxy.height = 57.6
                        ),
                        icon = icon("cubes"),
                        color = "lightblue"
                    ),
                    infoBox(
                        "Âge moyen",
                        value = withSpinner(
                            textOutput("age_moyen"),
                            type = 6,
                            size = .3,
                            proxy.height = 57.6
                        ),
                        icon = icon("person-cane"),
                        color = "lime"
                    ),
                    infoBox(
                        "Salaire horaire moyen",
                        value = withSpinner(
                            textOutput("wph_moyen"),
                            type = 6,
                            size = .3,
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
                        title = "Income level by race",
                        content = withSpinner(
                            plotlyOutput("income_level_race"),
                            type = 7,
                            size = .5
                        )
                    ),
                    box(
                        title = "State of previous residence",
                        content = withSpinner(
                            plotlyOutput("previous_residence"),
                            type = 7,
                            size = .5
                        )
                    ),
                    box(
                        title = "Globe",
                        content = withSpinner(
                            globeOutput("globe"),
                            type = 7,
                            size = .5
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
