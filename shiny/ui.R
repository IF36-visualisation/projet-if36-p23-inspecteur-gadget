library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(bs4Dash)
library(shinycssloaders)

dashboardPage(
    dashboardHeader(
        title = "Census Income",
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Stats",
                tabName = "stats",
                icon = icon("arrow-trend-up")
            ),
            menuItem("Graphiques",
                tabName = "graphiques",
                icon = icon("chart-bar")
            )
        )
    ),
    dashboardBody(
        fluidRow(
            box(
                title = "Income level by race",
                shinycssloaders::withSpinner(
                    plotlyOutput("income_level_race"),
                    type = 8,
                    size = .5
                )
            ),
            box(
                title = "State of previous residence",
                shinycssloaders::withSpinner(
                    plotlyOutput("previous_residence"),
                    type = 8,
                    size = .5
                )
            )
        )
    ),
    dashboardControlbar(
        skinSelector()
    )
)
