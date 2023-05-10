library(tidyverse)
library(usmap)
library(gridExtra)

data <- read_csv("../census-income.csv")

# --------------------------------------------------------
ggplot(data, aes(x = income_level, fill = race)) +
    geom_bar() +
    labs(x = "Income Level", y = "Count", fill = "Race")

# weeks worked and wage per hour are not correlated
ggplot(data, aes(x = wage_per_hour, y = weeks_worked_in_year)) +
    geom_point(aes(color = race)) +
    labs(x = "Wage Per Hour", y = "Weeks Worked In Year", color = "Race")

# --------------------------------------------------------
ggplot(data, aes(x = income_level, fill = sex)) +
    geom_bar() +
    labs(x = "Income Level", y = "Count", fill = "Sex")

# --------------------------------------------------------
ggplot(data, aes(y = country_of_birth_self)) +
    geom_bar() +
    labs(x = "Count", y = "Country of Birth")

# --------------------------------------------------------
move <- data %>%
    filter(state_of_previous_residence != "Not in universe" &
        state_of_previous_residence != "?") %>%
    group_by(state_of_previous_residence) %>%
    summarise(count = n()) %>%
    arrange(desc(count)) %>%
    rename(state = state_of_previous_residence)
plot_usmap(data = move, values = "count") +
    scale_fill_continuous(
        low = "white", high = "red",
    ) +
    labs(title = "State of Previous Residence") +
    theme(
        legend.position = "right", legend.text = element_text(size = 10),
        legend.title = element_text(size = 12)
    )

# --------------------------------------------------------
capital <- data %>%
    select(capital_gains, capital_losses, dividends_from_stocks) %>%
    pivot_longer(
        cols = everything(),
        names_to = "variable",
        values_to = "value"
    ) %>%
    filter(value != 0)
ggplot(capital, aes(x = variable, y = value)) +
    geom_boxplot() +
    labs(title = "Gains, losses and dividends") +
    theme(text = element_text(size = 26))

# --------------------------------------------------------
capital_data <- data %>%
    select(capital_gains) %>%
    filter(capital_gains != 0)

capital_data <- data %>%
    select(capital_losses) %>%
    filter(capital_losses != 0)

dividends_data <- data %>%
    select(dividends_from_stocks) %>%
    filter(dividends_from_stocks != 0)

gains_plot <- ggplot(capital_data, aes(y = capital_gains)) +
    geom_boxplot() +
    labs(title = "Capital Gains", y = "Capital Gains")

losses_plot <- ggplot(capital_data, aes(y = capital_losses)) +
    geom_boxplot() +
    labs(title = "Capital Losses", y = "Capital Losses")

dividends_plot <- ggplot(dividends_data, aes(y = dividends_from_stocks)) +
    geom_boxplot() +
    labs(title = "Dividends From Stocks", y = "Dividends From Stocks")

print(grid.arrange(gains_plot, losses_plot, dividends_plot, nrow = 1))

# --------------------------------------------------------
ggplot(data, aes(x = age)) +
    geom_histogram(binwidth = 5) +
    labs(x = "Age", y = "Count") +
    theme(text = element_text(size = 26))
