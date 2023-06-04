library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(gridExtra)

data <- read_csv("./data/census-income.csv")


# Présentation du jeu de données

# distribution des âges du jeu de données
ggplot(data, aes(x = age)) +
    geom_density(fill = "blue") +
    labs(title = "Age distribution", x = "Age", y = "Count")

# distribution des ethnies sur le jeu de données

data$race <- gsub("Asian or Pacific Islander", "Asian/Pacific", data$race)
data$race <- gsub("Amer Indian Aleut or Eskimo", "Natives", data$race)

ggplot(data, aes(x = race)) +
    geom_bar() +
    labs(title = "Distribution des ethnies", x = "Ethnies", y = "Distribution")

# distribution des genres dans le jeu de données
ggplot(data, aes(x = sex)) +
    geom_bar() +
    labs(title = "Distribution des genres", x = "Genres", y = "Distribution")

# Distribution en fonction du genre et de l'ethnie
ggplot(data, aes(x = sex, fill = race)) +
    geom_bar() +
    labs(title = "Distribution des genres", x = "Genres", y = "Distribution")


# Répartition des hommes et des femmes selon l'âge
ggplot(data = data, aes(x = age, color = sex)) +
    geom_line(stat = "count") +
    xlab("Âge") +
    ylab("Nombre de personnes") +
    ggtitle("Nombre d'hommes et de femmes par âge")

# countries of birth (not relevant due to the us)
ggplot(data, aes(y = country_of_birth_self)) +
    geom_bar() +
    labs(
        title = "Country of birth",
        x = "Count", y = "Country"
    )

# pyramides des âges
ages <- data %>%
    mutate(age_range = cut(age, breaks = seq(min(data$age), max(data$age), 5)))

ggplot(data = ages, aes(x = as.factor(age_range), fill = sex)) +
    geom_bar(data = subset(ages, sex == "Female")) +
    geom_bar(
        data = subset(ages, sex == "Male"),
        aes(y = after_stat(count) * (-1))
    ) +
    coord_flip() +
    labs(title = "Pyramide des âges", x = "Âge", y = "Nombre de personnes")





# Analyse
# INCOME
# income level by race (not relevant with 50000+, too crowded)
ggplot(data, aes(x = income_level, fill = race)) +
    geom_bar(position = "fill") +
    labs(
        title = "Income level by race",
        x = "Income Level", y = "Percentage", fill = "Race"
    )

# income level by sex
ggplot(data, aes(x = income_level, fill = sex)) +
    geom_bar(position = "fill") +
    labs(x = "Income Level", y = "Count", fill = "Sex")

# income level by race, male and female
ggplot(data, aes(x = sex, fill = race)) +
    geom_bar(position = "fill") +
    facet_wrap(~income_level) +
    labs(
        title = "Income level by race",
        x = "Income Level", y = "Percentage", fill = "Race"
    )

# income level by race, male, female - NO WHITE
no_white <- filter(data, race != "White")

ggplot(no_white, aes(x = sex, fill = race)) +
    geom_bar(position = "fill") +
    facet_wrap(~income_level) +
    labs(
        title = "Income level by race",
        x = "Income Level", y = "Percentage", fill = "Race"
    )

# average income level by age and race
wage <- data %>%
    filter(wage_per_hour != 0 & race != "Other" & age < 76)

average_income_by_age_race <-
    aggregate(wage_per_hour ~ age + race, data = wage, FUN = mean)

ggplot(data = average_income_by_age_race, aes(
    x = age, y = wage_per_hour,
    color = race
)) +
    geom_smooth(se = FALSE) +
    labs(
        title = "Average wage per hour by age and race",
        x = "Age", y = "Average wage per hour",
        color = "Race"
    )

# distribution of races by income level
library(scales)
income_percent <- data %>%
    group_by(income_level) %>%
    count(race) %>%
    mutate(percentage = n / sum(n))

ggplot(income_percent, aes(x = income_level, y = percentage, fill = race)) +
    geom_bar(position = "dodge", stat = "identity") +
    scale_y_continuous(labels = percent_format()) +
    labs(
        title = "Distribution of Races by Income Level",
        fill = "Race",
        x = "Income Level",
        y = "Percentage"
    )


# EMPLOYMENT
# employment rate by age
# version se base sur population totale
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
    labs(title = "Taux d'emploi par âge", x = "Age", y = "Taux d'emploi")

# version se basant sur la population active (en prenant en compte enfants et militaires)
major <- filter(data, data$age > 14)

employment_rate <- aggregate(
    major$full_or_part_time_employment_stat,
    by = list(major$age), FUN = function(x) {
        sum(x == "Full-time schedules" |
            x == "PT for econ reasons usually PT" |
            x == "PT for econ reasons usually FT" |
            x == "PT for non-econ reasons usually FT" |
            x == " Children or Armed Forces") / length(x)
    }
)

colnames(employment_rate) <- c("age", "employment_rate")

ggplot(data = employment_rate, aes(x = age, y = employment_rate)) +
    geom_line(color = "blue") +
    labs(title = "Taux d'emploi par âge", x = "Age", y = "Taux d'emploi")

# Taux d'emploi par ethnie et par âge
R_Empl <- data %>%
    filter(age > 14 & age < 80 & race != "Other")

taux_emploi <- aggregate(full_or_part_time_employment_stat ~ race + age, data = R_Empl, FUN = function(x) {
    taux <- sum(x == "Full-time schedules" |
        x == "PT for econ reasons usually PT" |
        x == "PT for econ reasons usually FT" |
        x == "PT for non-econ reasons usually FT" |
        x == " Children or Armed Forces") / length(x) * 100
})

colnames(taux_emploi) <- c("Ethnies", "age", "emploi")

ggplot(data = taux_emploi, aes(x = age, y = emploi, color = Ethnies)) +
    geom_smooth(se = FALSE) +
    xlab("Âge") +
    ylab("Taux d'emploi (%)") +
    ggtitle("Taux d'emploi par ethnie et âge")

# job loss according to race
job_loss <- data %>%
    filter(reason_for_unemployment != "Not in universe")

ggplot(job_loss, aes(x = reason_for_unemployment, fill = race)) +
    geom_bar() +
    labs(title = "Reason for unemployment", x = "Reason", y = "Count")

# weeks worked and wage per hour : not correlated
ggplot(data, aes(x = wage_per_hour, y = weeks_worked_in_year)) +
    geom_point(aes(color = race)) +
    labs(
        title = "Wage according to weeks worked in a year",
        x = "Wage Per Hour", y = "Weeks Worked In Year"
    )


# taux d'emploi par genre
taux_emploi <- aggregate(full_or_part_time_employment_stat ~ sex, data = major, FUN = function(x) {
    taux <- sum(x == "Full-time schedules" |
        x == "PT for econ reasons usually PT" |
        x == "PT for econ reasons usually FT" |
        x == "PT for non-econ reasons usually FT") / length(x)
})

ggplot(data = taux_emploi) +
    geom_bar(aes(x = sex, y = full_or_part_time_employment_stat), stat = "identity", fill = "Purple", width = 0.5) +
    xlab("Genre") +
    ylab("Taux d'emploi (%)") +
    ggtitle("Taux d'emploi chez les hommes et les femmes")

# major industry code by sex
industry <- data %>%
    filter(major_industry_recode != "Not in universe or children")

ggplot(industry, aes(y = major_industry_recode, fill = sex)) +
    geom_bar() +
    scale_fill_manual(values = c("Male" = "blue", "Female" = "pink")) +
    labs(x = "Count", y = "Major Industry Recode")









# CAPITAL AND EDUCATION
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

# wage per hour by education
education_order <- c(
    "Less than 1st grade",
    "1st 2nd 3rd or 4th grade",
    "5th or 6th grade",
    "7th and 8th grade",
    "9th grade",
    "10th grade",
    "11th grade",
    "12th grade no diploma",
    "High school graduate",
    "Some college but no degree",
    "Associates degree-occup /vocational",
    "Associates degree-academic program",
    "Bachelors degree(BA AB BS)",
    "Masters degree(MA MS MEng MEd MSW MBA)",
    "Prof school degree (MD DDS DVM LLB JD)",
    "Doctorate degree(PhD EdD)"
)

education <- data %>%
    filter(wage_per_hour != 0) %>%
    filter(education != "Children") %>%
    mutate(education = factor(
        education,
        levels = education_order
    )) %>%
    group_by(education, race, sex) %>%
    summarise(wage_per_hour = mean(wage_per_hour))

ggplot(education, aes(x = wage_per_hour, y = education)) +
    geom_bar(stat = "identity") +
    labs(
        title = "Wage per hour by education",
        x = "Wage per hour", y = "Education"
    )

# niveau d'étude en fonction de la race
ggplot(education, aes(y = education, fill = race)) +
    geom_bar(position = "fill")

# niveau d'étude en fonction du sexe
ggplot(education, aes(y = education, fill = sex)) +
    geom_bar(position = "fill")




# MIGRATION
# us map : states of previous residences
library(usmap)

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

# Pays de naissance des personnes interrogées
# Pays différents
# countries of birth (without the us)
world <- data %>%
    filter(country_of_birth_self != "United-States")

ggplot(world, aes(y = country_of_birth_self)) +
    geom_bar() +
    labs(x = "Count", y = "Country of Birth")

# US vs AUTRE
counts <- table(data$country_of_birth_self)
nb_etats_unis <- counts["United-States"]
nb_autres_pays <- sum(counts) - nb_etats_unis

graph_data <- data.frame(
    Pays = c("États-Unis", "Autres"),
    Fréquence = c(counts["United-States"], sum(counts) - counts["United-States"])
)

ggplot(data = graph_data, aes(x = Fréquence, y = Pays, fill = Pays)) +
    geom_bar(stat = "identity", width = 0.5) +
    xlab("Fréquence") +
    ylab("Pays") +
    ggtitle("Comparaison du nombre de personnes ayant les EU comme pays de naissance et le reste")
