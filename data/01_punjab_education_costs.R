
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


# Calculate weighted percentiles
weighted_percentile <- function(x, w, p) {
  order_index <- order(x)
  
  x <- x[order_index]
  w <- w[order_index]
  
  cumulative <- cumsum(w) / sum(w)
  
  x[which(cumulative >= p)[1]]
}

student_count <- nrow(students)

unweighted_median <- median(students$ed_total)

weighted_median <- weighted_percentile(
  students$ed_total, students$hhweight, 0.50
)

p10 <- weighted_percentile(
  students$ed_total, students$hhweight, 0.10
)

p90 <- weighted_percentile(
  students$ed_total, students$hhweight, 0.90
)

spending_ratio <- p90 / p10

# Select spending range for histogram
graph_data <- subset(
  students,
  ed_total >= 100 & ed_total <= 1000000
)

excluded <- student_count - nrow(graph_data)

# Print the calculated statistics
cat("\nRURAL PUNJAB - EDUCATION SPENDING\n")
cat("Students:", student_count, "\n")
cat("Unweighted median:", unweighted_median, "\n")
cat("Weighted median:", weighted_median, "\n")
cat("Weighted P10:", p10, "\n")
cat("Weighted P90:", p90, "\n")
cat("P90/P10 ratio:",
    sprintf("%.2f", spending_ratio), "\n")
cat("Excluded observations:", excluded, "\n")

