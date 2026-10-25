
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


# Create weighted spending histogram
spending_plot <- ggplot(
  graph_data,
  aes(x = log10(ed_total), weight = hhweight)
) +
  geom_histogram(
    aes(y = after_stat(density)),
    binwidth = 0.1,
    boundary = 2,
    fill = "grey75",
    color = "grey30"
  ) +
  geom_vline(
    xintercept = log10(weighted_median),
    linetype = "dashed",
    linewidth = 0.8
  ) +
  geom_vline(
    xintercept = log10(p90),
    linetype = "dashed",
    color = "grey45",
    linewidth = 0.8
  ) +
  annotate(
    "label",
    x = log10(weighted_median),
    y = Inf,
    label = paste("Median: Rs", weighted_median),
    vjust = 1.2,
    size = 3
  ) +
  annotate(
    "label",
    x = log10(p90),
    y = Inf,
    label = paste("P90: Rs", p90),
    vjust = 3,
    size = 3
  ) +
  scale_x_continuous(
    breaks = 2:6,
    labels = c("100", "1,000", "10,000",
               "100,000", "1,000,000")
  ) +
  coord_cartesian(xlim = c(2, 6)) +
  labs(
    title = "Education spending in rural Punjab",
    subtitle = paste0(
      "Weighted distribution | P90/P10 = ",
      sprintf("%.2f", spending_ratio)
    ),
    x = "Annual education spending (Rs, log10 scale)",
    y = "Weighted density per log10 unit",
    caption = paste0(
      "Source: PSLM | Weight: hhweight",
      "\nStudents: ", student_count,
      " | Excluded: ", excluded
    )
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    plot.caption = element_text(hjust = 0)
  )

# Display the graph
print(spending_plot)

# Save the graph
ggsave(
  "figures/punjab_spending_distribution.svg",
  plot = spending_plot,
  width = 10,
  height = 6
)

cat("Histogram saved successfully.\n")

