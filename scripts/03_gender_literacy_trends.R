
# ECO346 Assignment 1
# Question 3 - Gender and Literacy
# Variant 0: Rural Punjab

library(ggplot2)

# Load and combine datasets
persons <- read.csv("data/pslm_person_subset.csv")
households <- read.csv("data/pslm_hh_subset.csv")

stopifnot(!anyDuplicated(households$hhid))

survey <- merge(
  persons,
  households[, c("hhid", "hhweight",
                 "prov_code", "urban_rural")],
  by = "hhid"
)

# Select eligible people in rural Punjab
literacy <- subset(
  survey,
  prov_code == 2 & urban_rural == 1 &
    age >= 10 & age <= 64 &
    sex %in% c(1, 2) &
    literate %in% c(0, 1) &
    !is.na(hhweight) & hhweight > 0
)

# Create age bands
age_labels <- paste0(
  seq(10, 60, 5), "-",
  seq(14, 64, 5)
)

literacy$age_band <- cut(
  literacy$age,
  breaks = seq(10, 65, 5),
  labels = age_labels,
  right = FALSE
)

cat("Total literacy observations:",
    nrow(literacy), "\n")

# Weighted number of literate people
literacy$weighted_lit <- literacy$literate *
  literacy$hhweight

# Count each observation
literacy$n <- 1

# Summarize by age group and sex
rates <- aggregate(
  cbind(weighted_lit, hhweight, n) ~ age_band + sex,
  data = literacy,
  FUN = sum
)

# Calculate weighted literacy percentage
rates$rate <- 100 * rates$weighted_lit /
  rates$hhweight

# Give names to the two groups
rates$gender <- ifelse(
  rates$sex == 1, "Male", "Female"
)

# Assign midpoints to age bands
rates$age_mid <- seq(12, 62, 5)[
  match(as.character(rates$age_band), age_labels)
]

# Convert to a wide table for comparison
comparison <- reshape(
  rates[, c("age_band", "gender", "n", "rate")],
  idvar = "age_band",
  timevar = "gender",
  direction = "wide"
)

comparison <- comparison[
  match(age_labels, as.character(comparison$age_band)),
]

# Calculate the gender gap in percentage points
comparison$gap <- comparison$rate.Male -
  comparison$rate.Female

# Find the largest absolute difference
largest_gap <- comparison[
  which.max(abs(comparison$gap)), 
]

# Print the age-band table
results_table <- data.frame(
  Age_Group = as.character(comparison$age_band),
  Male_N = comparison$n.Male,
  Male_Rate = round(comparison$rate.Male, 1),
  Female_N = comparison$n.Female,
  Female_Rate = round(comparison$rate.Female, 1),
  Gap_pp = round(comparison$gap, 1)
)

print(results_table, row.names = FALSE)

cat("\nLargest gender gap:",
    as.character(largest_gap$age_band), "\n")

cat("Gap in percentage points:",
    round(largest_gap$gap, 1), "\n")

# Position of the largest gender gap
gap_age <- seq(12, 62, 5)[
  match(as.character(largest_gap$age_band), age_labels)
]

# Set gender as a factor for consistent plotting
rates$gender <- factor(
  rates$gender,
  levels = c("Male", "Female")
)

# Create the improved visualization
literacy_plot <- ggplot(
  rates,
  aes(x = age_mid, y = rate,
      color = gender, group = gender)
) +
  geom_line(linewidth = 1) +
  
  # Solid points for groups with at least 30 people
  geom_point(
    data = subset(rates, n >= 30),
    shape = 16,
    size = 2.8
  ) +
  
  # Hollow points for groups with fewer than 30
  geom_point(
    data = subset(rates, n < 30),
    shape = 21,
    fill = "white",
    size = 3,
    stroke = 1.1
  ) +
  
  # Direct labels at the right end of both lines
  geom_text(
    data = subset(rates, age_mid == 62),
    aes(x = age_mid + 1.5, label = gender),
    hjust = 0,
    fontface = "bold",
    size = 4
  ) +
  
  # Highlight the widest gender gap
  annotate(
    "segment",
    x = gap_age,
    xend = gap_age,
    y = largest_gap$rate.Female,
    yend = largest_gap$rate.Male,
    linetype = "dashed",
    color = "grey40",
    linewidth = 0.7
  ) +
  
  annotate(
    "label",
    x = gap_age,
    y = min(98, max(largest_gap$rate.Male,
                    largest_gap$rate.Female) + 9),
    label = paste0(
      "Largest gap: ",
      sprintf("%.1f", abs(largest_gap$gap)),
      " pp"
    ),
    size = 3
  ) +
  
  scale_color_manual(
    values = c(
      "Male" = "#343434",
      "Female" = "#A16651"
    )
  ) +
  
  scale_x_continuous(
    breaks = seq(12, 62, 5),
    labels = age_labels,
    limits = c(10, 74)
  ) +
  
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, 20),
    labels = function(x) paste0(x, "%")
  ) +
  
  labs(
    title = "Gender differences in literacy across rural Punjab",
    subtitle = "Household-weighted literacy rates by age group",
    x = "Age group (years)",
    y = "Literacy rate",
    caption = paste0(
      "Source: PSLM person and household datasets",
      " | Weight: hhweight",
      "\nAges 10-64 | N = ", nrow(literacy),
      " | Hollow points indicate groups with fewer than 30 people"
    )
  ) +
  
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor = element_blank(),
    plot.caption = element_text(hjust = 0, size = 8)
  )

# Show the graph
print(literacy_plot)

# Export SVG
ggsave(
  "figures/punjab_literacy_trends.svg",
  plot = literacy_plot,
  width = 11,
  height = 7
)

cat("Literacy graph saved successfully.\n")
