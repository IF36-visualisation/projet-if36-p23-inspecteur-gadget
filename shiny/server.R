library(dplyr)
library(readr)
library(ggplot2)
library(threejs)
library(maps)
library(plotly)
library(scales)
library(forcats)
library(shiny)
library(shiny.i18n)

data <- read_csv("../data/census-income.csv")

data$race <- gsub("Asian or Pacific Islander", "Asian/Pacific", data$race)
data$race <- gsub("Amer Indian Aleut or Eskimo", "Natives", data$race)

hispanic_latino <- c("Mexican (Mexicano)", "Puerto Rican", "Cuban", "Central or South American", "Other Spanish", "Chicano", "Mexican-American")
data$race <- ifelse(data$hispanic_origin %in% hispanic_latino, "Hispanic/Latino", data$race)

data <- data %>% rename(wage_per_month = wage_per_hour)


# ----------------- wage per hour without 0 -----------------
wph_nozero <- data %>%
    filter(wage_per_month != 0)
# -----------------------------------------------------------


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

state_map <- state_map %>% colorbar(
    title = "Effectif",
    y = 0.9
)

state_map <- state_map %>% layout(
    geo = g,
    margin = list(l = 0, r = 0, b = 0, t = 0)
)
# -----------------------------------------------------------------


# -------------------------- globe --------------------------

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
# -----------------------------------------------------------


server <- function(input, output) {
    # -------------- pyramides des âges ---------------
    pyramid_filtered <- reactive({
        filtered_ages <- data %>%
            filter(race %in% input$demog_race_selector) %>%
            mutate(age_range = cut(age,
                breaks = seq(min(data$age), max(data$age), 5), include.lowest = TRUE
            ))

        return(filtered_ages)
    })
    # -------------------------------------------------

    # -------------- distribution des ethnies et des genres  ---------------
    race_sex_distribution_filtered <- reactive({
        if (input$demog_format_selector == "Pourcentage") {
            plot <- ggplot(data, aes(x = sex, fill = race)) +
                geom_bar(position = "fill") +
                scale_y_continuous(labels = percent_format()) +
                labs(
                    x = "Genres", y = "Distribution",
                    fill = "Ethnies"
                )
        } else {
            plot <- ggplot(data, aes(x = sex, fill = race)) +
                geom_bar() +
                labs(
                    x = "Genres", y = "Distribution",
                    fill = "Ethnies"
                )
        }

        return(plot)
    })
    # -------------------------------------------------

    # -------------- pays de naissance  ---------------
    birth_data <- data %>%
        filter(country_of_birth_self != "?")

    birth_country_filtered <- reactive({
        if (input$demog_country_selector == "Tous") {
            filtered_data <- birth_data
        } else {
            filtered_data <- birth_data %>%
                filter(country_of_birth_self != "United-States")
        }

        if (input$demog_country_order == "Croissant") {
            plot <- ggplot(filtered_data, aes(y = fct_infreq(country_of_birth_self))) +
                geom_bar() +
                labs(x = "Nombre de personnes", y = "Pays de naissance")
        } else {
            plot <- ggplot(filtered_data, aes(y = fct_rev(fct_infreq(country_of_birth_self)))) +
                geom_bar() +
                labs(x = "Nombre de personnes", y = "Pays de naissance")
        }

        return(plot)
    })

    # -------------------------------------------------

    # -------------- niveau de revenu par ethnie et genre ---------------
    race_income_filtered <- reactive({
        races_income <- data %>%
            filter(race != "Other") %>%
            filter(race %in% input$rev_selected_race)

        plot <- ggplot(races_income, aes(x = sex, fill = race)) +
            geom_bar(position = "fill") +
            facet_wrap(~income_level) +
            scale_y_continuous(labels = percent_format()) +
            labs(
                x = "Niveau de revenu", y = "Distribution", fill = "Ethnie"
            )

        return(plot)
    })
    # -------------------------------------------------

    # -------------- salaire mensuel moyen par ethnie ou genre ---------------
    wage <- data %>%
        filter(wage_per_month != 0 & race != "Other")

    wage_per_month_filtered <- reactive({
        average_wpm_by_age <- wage %>%
            filter(age >= input$rev_selected_age[1] & age <= input$rev_selected_age[2]) %>%
            aggregate(wage_per_month ~ age + race + sex, FUN = mean)

        aes_variable <- if (input$rev_selected_filter == "Ethnie") {
            aes(x = age, y = wage_per_month, color = race)
        } else {
            aes(x = age, y = wage_per_month, color = sex)
        }

        plot <- ggplot(data = average_wpm_by_age, aes_variable) +
            geom_smooth(se = FALSE, size = ifelse(input$rev_selected_filter == "Ethnie", 0.5, 1)) +
            labs(
                x = "Âge",
                y = "Salaire mensuel moyen",
                color = if (input$rev_selected_filter == "Ethnie") {
                    "Ethnie"
                } else {
                    "Genre"
                }
            )

        return(plot)
    })

    # ------------------------------------------------------------------------

    # -------------- taux d'emploi --------------------
    employment_rate_filtered <- reactive({
        adults <- data %>%
            filter(education != "Children") %>%
            filter(age >= input$employ_selected_age[1] & age <= input$employ_selected_age[2])

        color_variable <- if (input$employ_selected_race_sex == "Ethnie") {
            adults$race
        } else {
            adults$sex
        }

        employment_rate <- aggregate(
            adults$full_or_part_time_employment_stat,
            by = list(adults$age), FUN = function(x) {
                sum(x == "Full-time schedules" |
                    x == "PT for econ reasons usually PT" |
                    x == "PT for econ reasons usually FT" |
                    x == "PT for non-econ reasons usually FT" |
                    x == "Children or Armed Forces") / length(x)
            }
        )

        colnames(employment_rate) <- c("age", "rate")

        plot <- ggplot(data = employment_rate, aes(x = age, y = rate)) +
            geom_smooth(color = color_variable, se = FALSE) +
            labs(x = "Âge", y = "Taux d'emploi")

        return(plot)
    })
    # -------------------------------------------------

    # -------------- nombre moyen de semaine travaillées dans l'année selon l'âge ---------------
    weeks_worked_filtered <- reactive({
        weeks <- data %>%
            filter(age >= input$employ_selected_age[1] & age <= input$employ_selected_age[2])

        color_variable <- if (input$employ_selected_race_sex == "Ethnie") {
            weeks$race
        } else {
            weeks$sex
        }

        plot <- ggplot(weeks, aes(x = age, y = weeks_worked_in_year)) +
            geom_smooth(aes(color = color_variable), se = FALSE, size = 0.5) +
            labs(
                x = "Âge",
                y = "Nombre de semaines travaillées dans l'année",
                color = if (input$employ_selected_race_sex == "Ethnie") {
                    "Ethnie"
                } else {
                    "Genre"
                }
            )

        return(plot)
    })
    # -------------------------------------------------------------------------------------------
    
    # -------------- industry et occupation ---------------
    industry <- data %>%
        filter(major_industry_recode != "Not in universe or children" &
            major_occupation_recode != "Not in universe or children")

    industry_occupation_filtered <- reactive({
        y_variable <- if (input$employ_selected_industry_occupation == "Industrie") {
            if (input$employ_industry_occupation_order == "Décroissant") {
                industry$major_industry_recode %>%
                    fct_infreq() %>%
                    fct_rev()
            } else {
                industry$major_industry_recode %>% fct_infreq()
            }
        } else {
            if (input$employ_industry_occupation_order == "Décroissant") {
                industry$major_occupation_recode %>%
                    fct_infreq() %>%
                    fct_rev()
            } else {
                industry$major_occupation_recode %>% fct_infreq()
            }
        }

        fill_variable <- if (input$employ_selected_industry_occupation_filter == "Ethnie") {
            industry$race
        } else {
            industry$sex
        }

        plot <- ggplot(industry, aes(y = y_variable, fill = fill_variable)) +
            geom_bar() +
            labs(
                x = "Nombre de personnes",
                y = if (input$employ_selected_industry_occupation == "Industrie") {
                    "Industrie"
                } else {
                    "Occupation"
                },
                fill = if (input$employ_selected_industry_occupation_filter == "Ethnie") {
                    "Ethnie"
                } else {
                    "Genre"
                }
            ) +
            theme(axis.text.y = element_text(size = 8))
        
        return(plot)
    })
    # -----------------------------------------------------

    output$annee_recensement <- renderText({
        "1994"
    })
    output$nb_observations <- renderText({
        format(nrow(data), big.mark = " ")
    })
    output$nb_dimensions <- renderText({
        ncol(data)
    })
    output$age_moyen <- renderText({
        round(mean(data$age))
    })
    output$age_median <- renderText({
        median(data$age)
    })
    output$wpm_moyen <- renderText({
        round(mean(wph_nozero$wage_per_month))
    })
    output$state_map <- renderPlotly({
        state_map
    })
    output$globe <- renderGlobe({
        globe
    })
    output$ages_pyramid <- renderPlotly({
        ggplot(data = pyramid_filtered(), aes(x = as.factor(age_range), fill = sex)) +
            geom_bar(data = subset(pyramid_filtered(), sex == "Female")) +
            geom_bar(
                data = subset(pyramid_filtered(), sex == "Male"),
                aes(y = after_stat(count) * (-1))
            ) +
            coord_flip() +
            labs(
                x = "Âge", y = "Nombre de personnes",
                fill = "Genre"
            )
    })
    output$race_sex_distribution <- renderPlotly({
        race_sex_distribution_filtered()
    })
    output$birth_country <- renderPlotly({
        birth_country_filtered()
    })
    output$race_income <- renderPlotly({
        race_income_filtered()
    })
    output$wage_per_month <- renderPlotly({
        wage_per_month_filtered()
    })
    output$employment_rate <- renderPlotly({
        employment_rate_filtered()
    })
    output$weeks_worked <- renderPlotly({
        weeks_worked_filtered()
    })
    output$industry_occupation <- renderPlotly({
        industry_occupation_filtered()
    })
}
