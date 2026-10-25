
# ECO346 Assignment 1
# Question 2 - Education Spending
# Variant 0: Rural Punjab

library(ggplot2)

# Read the two datasets
person <- read.csv("data/pslm_person_subset.csv")
household <- read.csv("data/pslm_hh_subset.csv")

# Combine household and individual data
stopifnot(!anyDuplicated(household$hhid))

survey <- merge(
  person,
  household[, c("hhid", "hhweight",
                 "prov_code", "urban_rural")],
  by = "hhid"
)

# Select rural Punjab
punjab <- subset(
  survey,
  prov_code == 2 & urban_rural == 1
)

# Keep students with positive education spending
students <- subset(
  punjab,
  !is.na(ed_total) & ed_total > 0 &
  !is.na(hhweight) & hhweight > 0
)

cat("Number of students:", nrow(students), "\n")
