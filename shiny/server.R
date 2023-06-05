library(dplyr)
library(readr)
library(ggplot2)
library(plotly)
library(shiny)

data <- read_csv("../data/census-income.csv")


# ----------------- income level by race -----------------
income_level_race_plot <- ggplot(data, aes(x = income_level, fill = race)) +
    geom_bar(position = "fill") +
    labs(
        x = "Income Level", y = "Percentage", fill = "Race"
    )
# ---------------------------------------------------------


# ------------- us map of state of previous residence -------------
previous_residence_data <- data %>%
    filter(state_of_previous_residence != "Not in universe" &
        state_of_previous_residence != "?" &
        state_of_previous_residence != "Abroad") %>%
    group_by(state_of_previous_residence) %>%
    summarise(count = n()) %>%
    arrange(desc(count)) %>%
    rename(state = state_of_previous_residence)

previous_residence_data$code <- state.abb[match(
    previous_residence_data$state, state.name
)]

previous_residence_data$hover <- paste0(
    previous_residence_data$state
)

g <- list(
    scope = "usa",
    projection = list(type = "albers usa")
)

state_map <- plot_geo(previous_residence_data, locationmode = "USA-states")

state_map <- state_map %>% add_trace(
    z = ~count, text = ~hover, locations = ~code,
    color = ~count, colors = "Reds"
)

state_map <- state_map %>% colorbar(title = "Count")

state_map <- state_map %>% layout(geo = g)
# -----------------------------------------------------------------


# ----------------- wage per hour without 0 -----------------
wph_nozero <- data %>%
    filter(wage_per_hour != 0)
# -----------------------------------------------------------


# --------------------- globe ---------------------
library(threejs)
library(maps)
library(tidyverse)

globe_data <- data %>%
    select(country_of_birth_self) %>%
    filter(country_of_birth_self != "?" &
        country_of_birth_self != "Outlying-U S (Guam USVI etc)" &
        country_of_birth_self != "Yugoslavia" &
        country_of_birth_self != "United-States") %>%
    mutate(
        country_of_birth_self = replace(
            country_of_birth_self,
            country_of_birth_self %in% c("England", "Scotland"),
            "United Kingdom"
        ),
        country_of_birth_self = replace(
            country_of_birth_self,
            country_of_birth_self == "Columbia",
            "Colombia"
        ),
        country_of_birth_self = replace(
            country_of_birth_self,
            country_of_birth_self == "Holand Netherlands",
            "Netherlands"
        )
    ) %>%
    transform(country_of_birth_self = sub("-", " ", country_of_birth_self))

globe_data <- distinct(globe_data, country_of_birth_self)

map_data <- map_data("world")
coordinates <- map_data[
    match(globe_data$country_of_birth_self, map_data$region), c("long", "lat")
]

globe_data$longitude <- coordinates$long
globe_data$latitude <- coordinates$lat

globe_data$end_long <- -100.094673
globe_data$end_lat <- 40.165441

arcs_data <- globe_data %>% select(latitude, longitude, end_lat, end_long)

globe <- globejs(
    arcs = arcs_data,
    rotationlat = 0.5,
    rotationlong = 0.2,
    atmosphere = TRUE,
    arcsOpacity = 0.5,
    arcsColor = "white"
)
# -------------------------------------------------


server <- function(input, output) {
    output$nb_observations <- renderText({
        nrow(data)
    })
    output$nb_dimensions <- renderText({
        ncol(data)
    })
    output$age_moyen <- renderText({
        round(mean(data$age))
    })
    output$wph_moyen <- renderText({
        round(mean(wph_nozero$wage_per_hour))
    })
    output$globe <- renderGlobe({
        globe
    })
    output$state_map <- renderPlotly({
        state_map
    })
}
