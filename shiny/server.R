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


# ----------------- wage per hour without 0 -----------------
wph_nozero <- data %>%
    filter(wage_per_hour != 0)
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
    ages <- data %>%
        mutate(age_range = cut(age,
            breaks = seq(min(data$age), max(data$age), 5), include.lowest = TRUE
        ))

    pyramid_filtered <- reactive({
        selected_race <- input$demog_race_selector
        if (selected_race == "Toutes") {
            return(ages)
        }

        filtered_ages <- ages %>%
            filter(
                race == input$demog_race_selector
            )
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
    birth_country_filtered <- reactive({
        if (input$demog_country_selector == "Tous") {
            if (input$demog_country_order == "Croissant") {
                birth_countries <- ggplot(data, aes(y = fct_infreq(country_of_birth_self))) +
                    geom_bar() +
                    labs(
                        x = "Nombre de personnes", y = "Pays de naissance"
                    )
                return(birth_countries)
            } else {
                birth_countries <- ggplot(data, aes(y = fct_rev(fct_infreq(country_of_birth_self)))) +
                    geom_bar() +
                    labs(
                        x = "Nombre de personnes", y = "Pays de naissance"
                    )
                return(birth_countries)
            }
        } else {
            filtered_data <- data %>%
                filter(country_of_birth_self != "United-States")
            if (input$demog_country_order == "Croissant") {
                birth_countries <- ggplot(filtered_data, aes(y = fct_infreq(country_of_birth_self))) +
                    geom_bar() +
                    labs(
                        x = "Nombre de personnes", y = "Pays de naissance"
                    )
                return(birth_countries)
            } else {
                birth_countries <- ggplot(filtered_data, aes(y = fct_rev(fct_infreq(country_of_birth_self)))) +
                    geom_bar() +
                    labs(
                        x = "Nombre de personnes", y = "Pays de naissance"
                    )
                return(birth_countries)
            }
        }
    })
    # -------------------------------------------------

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
}
