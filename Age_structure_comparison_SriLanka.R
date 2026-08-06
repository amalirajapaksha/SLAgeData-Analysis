library(dplyr)
library(tidyr)
library(ggplot2)
library(SLpopData)
library(plotly)

# Create country-level age structure by year
country_age <- DISpop_by_FiveYearAgeGroup %>%
  group_by(Year) %>%
  summarise(
    Total = sum(Total, na.rm = TRUE),
    
    Young = sum(
      Age_0_4 + Age_5_9 + Age_10_14,
      na.rm = TRUE
    ),
    
    Working_Age = sum(
      Age_15_19 + Age_20_24 + Age_25_29 +
        Age_30_34 + Age_35_39 + Age_40_44 +
        Age_45_49 + Age_50_54 + Age_55_59 +
        Age_60_64,
      na.rm = TRUE
    ),
    
    Elderly = sum(
      Age_65_69 + Age_70_74 + Age_75_79 +
        Age_80_84 + Age_85_89 + Age_90_94 +
        Age_95_plus,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  pivot_longer(
    cols = c(Young, Working_Age, Elderly),
    names_to = "Age_Group",
    values_to = "Population"
  ) %>%
  mutate(
    Percentage = (Population / Total) * 100,
    Age_Group = factor(
      Age_Group,
      levels = c("Young", "Working_Age", "Elderly"),
      labels = c(
        "Young (0-14)",
        "Working Age (15-64)",
        "Elderly (65+)"
      )
    ),
    Year = factor(Year)
  )


# Plot
p <- ggplot(
  country_age,
  aes(
    x = Age_Group,
    y = Percentage,
    fill = Year
  )
) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.7
  ) +
  labs(
    title = "Age Structure Comparison of Sri Lanka: 2012 vs 2024",
    x = "Age Group",
    y = "Population Percentage (%)",
    fill = "Year"
  ) +
  scale_fill_manual(
    values = c(
      "2012" = "#F39C12",
      "2024" = "#27AE60"
    )
  ) +
  theme_minimal()

p
