library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(plotly)
library(gridExtra)
library(scales)
library(stringr)

data <- read_csv("./data/census-income.csv")

# Présentation du jeu de données

# distribution des âges du jeu de données
ggplot(data, aes(x = age)) +
    geom_density(fill = "blue") +
    labs(title = "Age distribution", x = "Age", y = "Count")

# distribution des ethnies sur le jeu de données

data$race <- gsub("Asian or Pacific Islander", "Asian/Pacific", data$race)
data$race <- gsub("Amer Indian Aleut or Eskimo", "Natives", data$race)

ggplot(data, aes(x = race, fill = race)) +
    geom_bar() +
    labs(title = "Distribution des ethnies", x = "Ethnies", y = "Distribution") +
    theme(text = element_text(size = 26))

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
    mutate(age_range = cut(age,
        breaks = seq(min(data$age), max(data$age), 5), include.lowest = TRUE
    ))

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

# average wage per hour by age and race
wage <- data %>%
    filter(wage_per_hour != 0 & race != "Other" & age < 76)

average_wph_by_age_race <-
    aggregate(wage_per_hour ~ age + race, data = wage, FUN = mean)

ggplot(data = average_wph_by_age_race, aes(
    x = age, y = wage_per_hour,
    color = race
)) +
    geom_smooth(se = FALSE) +
    labs(
        title = "Average wage per hour by age and race",
        x = "Age", y = "Average wage per hour",
        color = "Race"
    )

# salaire horaire moyen en fonction du genre et de l'âge
average_wph_by_age_sex <-
    aggregate(wage_per_hour ~ age + sex, data = wage, FUN = mean)

ggplot(data = average_wph_by_age_sex, aes(
    x = age, y = wage_per_hour,
    color = sex
)) +
    geom_smooth(se = FALSE) +
    labs(
        title = "Salaire mensuel moyen par âge et genre",
        x = "Age", y = "Average wage per hour",
        color = "Sex"
    ) +
    theme(aspect.ratio = 1, text = element_text(size = 26))

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
        title = "Distribution des ethnies par niveau de revenu",
        fill = "Ethnie",
        x = "Niveau de revenu",
        y = "Distribution (%)"
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
    group_by(education, race, sex, major_occupation_recode) %>%
    summarise(wage_per_hour = mean(wage_per_hour))

ggplot(education, aes(x = wage_per_hour, y = education)) +
    geom_bar(stat = "summary")

ggplot(education, aes(x = wage_per_hour, y = education)) +
    geom_boxplot()

# niveau d'étude en fonction de la race
ggplot(education, aes(y = education, fill = race)) +
    geom_bar(position = "fill") +
    labs(
        title = "Niveau d'étude en fonction de l'ethnie",
        x = "Pourcentage", y = "Niveau d'étude",
        fill = "Ethnie"
    ) +
    theme(
        text = element_text(size = 25), legend.position = "bottom",
        legend.justification = c(2, 1), plot.title = element_text(hjust = 2.7, vjust = 2.12),
        aspect.ratio = 2.5
    ) +
    guides(fill = guide_legend(nrow = 2))

# niveau d'étude en fonction du sexe
ggplot(education, aes(y = education, fill = sex)) +
    geom_bar(position = "fill")

# niveau d'étude en fonction du domaine d'activité
ggplot(education, aes(y = education, fill = major_occupation_recode)) +
    geom_bar(position = "fill") +
    theme(legend.spacing.y = unit(0.1, "cm")) +
    guides(fill = guide_legend(byrow = TRUE)) +
    labs(
        title = "Education by occupation",
        fill = "Occupation",
        x = "Percentage", y = "Education"
    )

# wage per hour en fonction du domaine d'activité (barchart)
ggplot(education, aes(y = major_occupation_recode, x = wage_per_hour)) +
    geom_bar(stat = "identity") +
    labs(
        title = "Wage per hour by occupation",
        x = "Wage per hour", y = "Occupation"
    ) +
    theme(
        text = element_text(size = 25), legend.position = "bottom",
        legend.justification = c(2, 1), plot.title = element_text(hjust = -14.5, vjust = 2.12),
        aspect.ratio = 1.6
    )

# wage per hour en fonction du domaine d'activité (boxplot)
ggplot(education, aes(y = major_occupation_recode, x = wage_per_hour)) +
    geom_boxplot() +
    labs(
        title = "Wage per hour by occupation",
        x = "Wage per hour", y = "Occupation"
    )



# MIGRATION
# us map : states of previous residences
library(usmap)

previous_residence_data <- data %>%
    filter(state_of_previous_residence != "Not in universe" &
        state_of_previous_residence != "?" &
        state_of_previous_residence != "Abroad") %>%
    group_by(state_of_previous_residence) %>%
    summarise(count = n()) %>%
    arrange(desc(count)) %>%
    rename(state = state_of_previous_residence)

plot_usmap(data = previous_residence_data, values = "count") +
    scale_fill_continuous(
        low = "white", high = "#D2042D",
    ) +
    labs(title = "State of Previous Residence") +
    theme(legend.position = "right", text = element_text(size = 25))

# us map BUT BETTER
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

map <- plot_geo(previous_residence_data, locationmode = "USA-states")

map <- map %>% add_trace(
    z = ~count, text = ~hover, locations = ~code,
    color = ~count, colors = "Reds"
)

map <- map %>% colorbar(title = "Count")

map <- map %>% layout(geo = g)
map

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

race_percent <- data %>%
    mutate(race = gsub("Asian or Pacific Islander", "Asian/Pacific", race)) %>%
    mutate(race = gsub("Amer Indian Aleut or Eskimo", "Natives", race)) %>%
    group_by(race) %>%
    count(race) %>%
    ungroup() %>%
    mutate(percentage = n / sum(n))

ggplot(race_percent, aes(x = race, y = percentage, fill = race)) +
    geom_bar(stat = "identity") +
    scale_y_continuous(labels = percent_format()) +
    labs(title = "Distribution des ethnies", x = "Ethnies", y = "Distribution") +
    theme(text = element_text(size = 25))

# type d'activité en fonction du genre
employment_stat <- data %>%
    filter(full_or_part_time_employment_stat != "Not in labor force" &
        full_or_part_time_employment_stat != "Unemployed full-time" &
        full_or_part_time_employment_stat != "Unemployed part- time" &
        full_or_part_time_employment_stat != "Children or Armed Forces") %>%
    mutate(full_or_part_time_employment_stat = gsub("PT for non-econ reasons usually FT", "Part-time", full_or_part_time_employment_stat)) %>%
    mutate(full_or_part_time_employment_stat = gsub("PT for econ reasons usually PT", "Part-time", full_or_part_time_employment_stat)) %>%
    mutate(full_or_part_time_employment_stat = gsub("PT for econ reasons usually FT", "Part-time", full_or_part_time_employment_stat)) %>%
    mutate(full_or_part_time_employment_stat = gsub("Full-time schedules", "Full-time", full_or_part_time_employment_stat))

ggplot(employment_stat, aes(x = full_or_part_time_employment_stat, fill = sex)) +
    geom_bar(position = "fill") +
    labs(title = "Type d'activité en fonction du genre", x = "Type d'activité", y = "Nombre de personnes")


# Proportion de femmes marioées ayant arrêté leurs études au 1st grade
married <- c("Married-civilian spouse present", "Married-spouse absent", "Married-A F spouse present")

women_married <- data %>% filter(sex == "Female" & marital_status %in% married)

women_married_first_grade <- women_married %>% filter(education == "1st 2nd 3rd or 4th grade" | education == "Less than 1st grade")

women_first_grade <- data %>% filter(sex == "Female" & education == "1st 2nd 3rd or 4th grade" | education == "Less than 1st grade")

women_total <- data %>% filter(sex == "Female")

women_first_grade_proportion <- (nrow(women_married_first_grade) / nrow(women_first_grade))
women_married_proportion <- (nrow(women_married) / nrow(women_total))

df <- data.frame(
    category = c("Femmes mariées 1st / Femmes 1st", "Femmes mariées / Total des femmes"),
    proportion = c(women_first_grade_proportion, women_married_proportion)
)

ggplot(df, aes(x = category, y = proportion, fill = category)) +
    geom_bar(stat = "identity") +
    scale_y_continuous(labels = percent_format()) +
    labs(
        title = "Proportion de femmes mariées ayant arrêté leurs études au 1st grade",
        x = "",
        y = "Proportion (%)"
    ) +
    theme(legend.position = "none")



######################################

education <- data %>%
    filter(wage_per_hour != 0) %>%
    filter(education != "Children") %>%
    filter(major_industry_recode == "Education" |
        major_industry_recode == "Hospital services" |
        major_industry_recode == "Medical except hospital") %>%
    mutate(education = factor(
        education,
        levels = education_order
    )) %>%
    group_by(education, race, sex, major_industry_recode) %>%
    summarise(wage_per_hour = mean(wage_per_hour), count = n())

ggplot(education, aes(x = major_industry_recode, y = wage_per_hour, fill = major_industry_recode)) +
    geom_bar(stat = "summary") +
    facet_wrap(~sex) +
    labs(
        title = "Salaire moyen par heure en fonction du sexe et du secteur d'activité",
        x = "Secteur d'activité", y = "Salaire moyen par heure",
        fill = "Secteur d'activité"
    ) +
    theme(text = element_text(size = 20)) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 10))
