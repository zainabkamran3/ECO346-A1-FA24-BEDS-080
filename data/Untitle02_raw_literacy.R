
# Question 4 - Original Literacy Graph
# Variant 0: Rural Punjab

library(ggplot2)

# Load datasets
person <- read.csv("data/pslm_person_subset.csv")
household <- read.csv("data/pslm_hh_subset.csv")

# Combine person and household records
stopifnot(!anyDuplicated(household$hhid))

survey <- merge(
  person,
  household[, c("hhid", "hhweight",
                "prov_code", "urban_rural")],
  by = "hhid"
)

# Keep rural Punjab only
punjab <- subset(
  survey,
  prov_code == 2 & urban_rural == 1
)

# Select people aged 10 to 64
literacy_data <- subset(
  punjab,
  age >= 10 & age <= 64 &
    literate %in% c(0, 1) &
    sex %in% c(1, 2) &
    !is.na(hhweight) & hhweight > 0
)

cat("Literacy sample:", nrow(literacy_data), "\n")
