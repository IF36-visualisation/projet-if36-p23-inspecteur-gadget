library(dplyr)
library(readr)
library(ggplot2)
library(plotly)
library(maps)
library(usmap)
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
        low = "white", high = "red",
    ) +
    theme(legend.position = "right")

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

unique(globe_data$country_of_birth_self)

count <- table(globe_data$country_of_birth_self)
globe_data$country_count <- count[
    as.character(globe_data$country_of_birth_self)
]
globe_data <- distinct(globe_data, country_of_birth_self, country_count)

map_data <- map_data("world")
coordinates <- map_data[
    match(globe_data$country_of_birth_self, map_data$region), c("long", "lat")
]

globe_data$longitude <- coordinates$long
globe_data$latitude <- coordinates$lat

globe <- globejs(
    lat = globe_data$latitude,
    long = globe_data$longitude,
    val = globe_data$country_count,
    color = "white",
    bodycolor = "steelblue",
    atmosphere = FALSE
)

# -------------------------------------------------

server <- function(input, output) {
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
