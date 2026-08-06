library(sf)
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)
library(SLpopData)


# Create age group percentages
map_data <- DISpop_by_FiveYearAgeGroup |>
  mutate(
    Young = Age_0_4 + Age_5_9 + Age_10_14,
    
    Working_Age = Age_15_19 + Age_20_24 + Age_25_29 +
      Age_30_34 + Age_35_39 + Age_40_44 +
      Age_45_49 + Age_50_54 + Age_55_59 +
      Age_60_64,
    
    Elderly = Age_65_69 + Age_70_74 + Age_75_79 +
      Age_80_84 + Age_85_89 + Age_90_94 +
      Age_95_plus
  ) |>
  select(
    District_Name,
    Year,
    Total,
    Young,
    Working_Age,
    Elderly
  ) |>
  pivot_longer(
    cols = c(Young, Working_Age, Elderly),
    names_to = "Age_Group",
    values_to = "Population"
  ) |>
  mutate(
    Percentage = Population / Total * 100,
    Year = factor(
      Year,
      levels = c("2012", "2024")
    )
  )

unique(map_sf$Year)


map_data <- map_data |>
  mutate(
    DISTRICT = toupper(District_Name),
    DISTRICT = recode(
      DISTRICT,
      "MONERAGALA" = "MONARAGALA"
    )
  )



map_data <- map_data |>
  mutate(
    Percentage_Category = cut(
      Percentage,
      breaks = c(0, 10, 20, 30, 40, 50, 100),
      labels = c(
        "0-10%",
        "10-20%",
        "20-30%",
        "30-40%",
        "40-50%",
        "50%+"
      ),
      include.lowest = TRUE
    )
  )



map_sf <- ceylon::district |>
  filter(DISTRICT != "[UNKNOWN]") |>
  left_join(map_data, by = "DISTRICT")



legend_colors <- c(
  "0-10%"   = "#ffffcc",
  "10-20%"  = "#c7e9b4",
  "20-30%"  = "#7fcdbb",
  "30-40%"  = "#41b6c4",
  "40-50%"  = "#2c7fb8",
  "50%+"    = "#253494"
)



create_age_map <- function(data, age_group, year_value){
  
  all_levels <- c(
    "0-10%",
    "10-20%",
    "20-30%",
    "30-40%",
    "40-50%",
    "50%+"
  )
  
  plot_data <- data |>
    filter(
      Age_Group == age_group,
      Year == year_value
    ) |>
    mutate(
      Percentage_Category = factor(
        Percentage_Category,
        levels = all_levels
      )
    )
  
  
  ggplot(plot_data) +
    geom_sf(
      aes(fill = Percentage_Category),
      color = "black",
      linewidth = 0.2,
      show.legend = TRUE
    ) +
    scale_fill_manual(
      values = c(
        "0-10%"   = "#ffffcc",
        "10-20%"  = "#c7e9b4",
        "20-30%"  = "#7fcdbb",
        "30-40%"  = "#41b6c4",
        "40-50%"  = "#2c7fb8",
        "50%+"    = "#253494"
      ),
      drop = FALSE,
      na.translate = FALSE,
      name = paste(age_group, "Population (%)")
    ) +
    labs(
      title = paste(year_value)
    ) +
    theme_void() +
    theme(
      plot.title = element_text(
        hjust = 0.5,
        size = 10
      ),
      legend.position = "right"
    )
}


young_2012 <- create_age_map(
  map_sf,
  "Young",
  "2012"
)

young_2024 <- create_age_map(
  map_sf,
  "Young",
  "2024"
)


working_2012 <- create_age_map(
  map_sf,
  "Working_Age",
  "2012"
)

working_2024 <- create_age_map(
  map_sf,
  "Working_Age",
  "2024"
)


elderly_2012 <- create_age_map(
  map_sf,
  "Elderly",
  "2012"
)

elderly_2024 <- create_age_map(
  map_sf,
  "Elderly",
  "2024"
)


young_combined <- young_2012 + young_2024 +
  plot_layout(guides = "collect") +
  plot_annotation(
    title = "District-wise Young (0–14) Population Comparison: 2012 vs. 2024"
  ) +
  theme(
    legend.position = "right"
  )

young_combined




working_combined <- working_2012 + working_2024 +
  plot_layout(guides = "collect") +
  plot_annotation(
    title = "District-wise Working-Age (15–64) Population Comparison: 2012 vs. 2024"
  ) +
  theme(
    legend.position = "right"
  )

working_combined





elderly_combined <- elderly_2012 + elderly_2024 +
  plot_layout(guides = "collect") +
  plot_annotation(
    title = "District-wise Elderly (65+) Population Comparison: 2012 vs. 2024"
  ) +
  theme(
    legend.position = "right"
  )

elderly_combined




