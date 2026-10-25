
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
