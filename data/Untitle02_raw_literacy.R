
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
