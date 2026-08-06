library(dplyr)
library(tidyr)
library(ggplot2)
library(SLpopData)

# Create country-level age structure by year
country_age <- DISpop_by_FiveYearAgeGroup |>
  group_by(Year) |>
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
  ) |>
  pivot_longer(
    cols = c(Young, Working_Age, Elderly),
    names_to = "Age_Group",
    values_to = "Population"
  ) |>
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




# Plot - Population Counts
p_count <- ggplot(
  country_age,
  aes(
    x = Age_Group,
    y = Population,
    fill = Year
  )
) +
  geom_col(
    position = position_dodge(width = 0.75),
    width = 0.7
  ) +
  geom_text(
    aes(label = scales::comma(Population)),
    position = position_dodge(width = 0.75),
    vjust = -0.3,
    size = 4
  ) +
  labs(
    title = "Age Structure Comparison of Sri Lanka: 2012 vs 2024",
    x = "Age Group",
    y = "Population Count",
    fill = "Year"
  ) +
  scale_fill_manual(
    values = c(
      "2012" = "#fc8d62",
      "2024" = "#66c2a5"
    )
  ) +
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.1))
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5
    )
  )

p_count





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
    position = position_dodge(width = 0.75),
    width = 0.7
  ) +
  geom_text(
    aes(label = sprintf("%.1f%%", Percentage)),
    position = position_dodge(width = 0.8),
    vjust = -0.3,
    size = 4
  ) +
  labs(
    title = "Age Structure Comparison of Sri Lanka: 2012 vs 2024",
    x = "Age Group",
    y = "Population Percentage (%)",
    fill = "Year"
  ) +
  scale_fill_manual(
    values = c(
      "2012" = "#fc8d62",
      "2024" = "#66c2a5"
    )
  ) +
  expand_limits(y = max(country_age$Percentage) * 1.1) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5
    )
  )

p


