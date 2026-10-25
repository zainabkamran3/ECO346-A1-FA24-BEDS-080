
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
