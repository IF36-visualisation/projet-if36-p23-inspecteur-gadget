library(dplyr)
library(readr)
library(ggplot2)
library(plotly)
library(usmap)
library(shiny)

data <- read_csv("../../census-income.csv")

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

server <- function(input, output) {
    output$income_level_race <- renderPlotly({
        income_level_race_plot
    })
    output$previous_residence <- renderPlotly({
        previous_residence_plot
    })
}
