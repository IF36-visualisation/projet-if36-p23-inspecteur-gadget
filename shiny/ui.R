library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(bs4Dash)

dashboardPage(
    skin = "purple",
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
                title = "Income level by race, by percentage or count",
                plotlyOutput("income_level_race")
            ),
            box(
                title = "State of previous residence",
                plotlyOutput("previous_residence")
            )
        )
    ),
    dashboardControlbar(
        skinSelector()
    )
)
