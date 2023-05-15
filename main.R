library(tidyverse)
library(usmap)
library(gridExtra)

data <- read_csv("../census-income.csv")


# income level by race (not relevant with 50000+, too crowded)
ggplot(data, aes(x = income_level, fill = race)) +
    geom_bar(position = "fill") +
    labs(
        title = "Income level by race",
        x = "Income Level", y = "Percentage", fill = "Race"
    )


# employment rate by age
employment_rate <- aggregate(
    data$full_or_part_time_employment_stat,
    by = list(data$age), FUN = function(x) {
        sum(x == "Full-time schedules" |
            x == "PT for econ reasons usually PT" |
            x == "PT for econ reasons usually FT" |
            x == "PT for non-econ reasons usually FT") / length(x)
    }
)

colnames(employment_rate) <- c("age", "employment_rate")

ggplot(data = employment_rate, aes(x = age, y = employment_rate)) +
    geom_line(color = "blue") +
    labs(title = "Employment rate by age", x = "Age", y = "Employment Rate")


# weeks worked and wage per hour : not correlated
ggplot(data, aes(x = wage_per_hour, y = weeks_worked_in_year)) +
    geom_point(aes(color = race)) +
    labs(
        title = "Wage according to weeks worked in a year",
        x = "Wage Per Hour", y = "Weeks Worked In Year"
    )


# income level by sex
ggplot(data, aes(x = income_level, fill = sex)) +
    geom_bar() +
    scale_fill_manual(values = c("Male" = "blue", "Female" = "pink")) +
    labs(x = "Income Level", y = "Count", fill = "Sex")


# average income level by age and race
wage <- data %>%
    filter(wage_per_hour != 0 & race != "Other")

average_income_by_age_race <-
    aggregate(wage_per_hour ~ age + race, data = wage, FUN = mean)

ggplot(data = average_income_by_age_race, aes(
    x = age, y = wage_per_hour,
    color = race
)) +
    geom_smooth(se = FALSE) +
    labs(
        title = "Average income level by age and race",
        x = "Age", y = "Average Income Level",
        color = "Race"
    )


# countries of birth (not relevant due to the us)
ggplot(data, aes(y = country_of_birth_self)) +
    geom_bar() +
    labs(x = "Count", y = "Country of Birth")


# countries of birth (without the us)
world <- data %>%
    filter(country_of_birth_self != "United-States")

ggplot(world, aes(y = country_of_birth_self)) +
    geom_bar() +
    labs(x = "Count", y = "Country of Birth")


# us map : states of previous residences
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
    theme(legend.position = "right")


# grouped gains, losses, and dividends
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
    labs(title = "Gains, losses and dividends")


# separated gains, losses, and dividends
gains_data <- data %>%
    select(capital_gains) %>%
    filter(capital_gains != 0)

losses_data <- data %>%
    select(capital_losses) %>%
    filter(capital_losses != 0)

dividends_data <- data %>%
    select(dividends_from_stocks) %>%
    filter(dividends_from_stocks != 0)

gains_plot <- ggplot(gains_data, aes(y = capital_gains)) +
    geom_boxplot() +
    labs(title = "Capital Gains", y = "Capital Gains")

losses_plot <- ggplot(losses_data, aes(y = capital_losses)) +
    geom_boxplot() +
    labs(title = "Capital Losses", y = "Capital Losses")

dividends_plot <- ggplot(dividends_data, aes(y = dividends_from_stocks)) +
    geom_boxplot() +
    labs(title = "Dividends From Stocks", y = "Dividends From Stocks")

print(grid.arrange(gains_plot, losses_plot, dividends_plot, nrow = 1))


# age distribution
ggplot(data, aes(x = age)) +
    geom_histogram(binwidth = 5) +
    labs(title = "Age distribution", x = "Age", y = "Count")


# major industry code by sex
industry <- data %>%
    filter(major_industry_recode != "Not in universe or children")

ggplot(industry, aes(y = major_industry_recode, fill = sex)) +
    geom_bar() +
    scale_fill_manual(values = c("Male" = "blue", "Female" = "pink")) +
    labs(x = "Count", y = "Major Industry Recode")


# job loss according to race
job_loss <- data %>%
    filter(reason_for_unemployment != "Not in universe")

ggplot(job_loss, aes(x = reason_for_unemployment, fill = race)) +
    geom_bar() +
    labs(title = "Reason for unemployment", x = "Reason", y = "Count")
