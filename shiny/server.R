library(dplyr)
library(readr)
library(ggplot2)
library(plotly)
library(maps)
library(usmap)
library(mapdata)
library(shiny)

data <- read_csv("../data/census-income.csv")

# income level by race
income_level_race_plot <- ggplot(data, aes(x = income_level, fill = race)) +
    geom_bar(position = "fill") +
    labs(
        x = "Income Level", y = "Percentage", fill = "Race"
    )


# us map of state of previous residence
previous_residence_data <- data %>%
    filter(state_of_previous_residence != "Not in universe" &
        state_of_previous_residence != "?") %>%
    group_by(state_of_previous_residence) %>%
    summarise(count = n()) %>%
    arrange(desc(count)) %>%
    rename(state = state_of_previous_residence)
previous_residence_plot <- plot_usmap(
    data = previous_residence_data,
    values = "count"
) +
    scale_fill_continuous(
        low = "white", high = "#DC143C",
    ) +
    theme(legend.position = "right") +
    labs(
        fill = "Number of people"
    )

# wage per hour without 0
wph_nozero <- data %>%
    filter(wage_per_hour != 0)

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
    output$income_level_race <- renderPlotly({
        income_level_race_plot
    })
    output$previous_residence <- renderPlotly({
        previous_residence_plot
    })
    output$globe <- renderGlobe({
        globe
    })
}
