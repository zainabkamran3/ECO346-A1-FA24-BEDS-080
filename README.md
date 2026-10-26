# ECO346-A1-FA24-BEDS-080
##Education Spending and Literacy in Rural Punjab
# Education Spending and Literacy in Rural Punjab

**Name:** Zainab Kamran  
**Registration No.:** FA24-BED-080  
**Course:** ECO346 — Data Visualization Techniques for Economists  
**Assignment:** 01  
**Variant:** 0 — Rural Punjab

## Project Overview

This assignment examines education spending and literacy patterns in rural Punjab using Pakistan Social and Living Standards Measurement (PSLM) data. The main objective is to understand educational differences through statistical analysis and clear data visualizations.

The analysis uses R for calculations and graphs, while Python is used to verify literacy results.

## Data Source

The project uses two datasets provided by the course instructor:

- `pslm_person_subset.csv` — Individual-level data.
- `pslm_hh_subset.csv` — Household-level data and survey weights.

Both datasets are merged using the household ID (`hhid`).

**Selected Region:** Rural Punjab (Province Code 2, Rural Code 1).

## Question 2 — Education Spending in Rural Punjab

This section examines the distribution of annual education expenditure among students in rural Punjab.

The person and household datasets were merged using `hhid`. Students with positive education spending and valid household weights were included in the analysis.

A weighted histogram was created using a logarithmic scale to make differences in spending easier to observe. The graph also highlights the weighted median and 90th percentile.

**R Script:** `scripts/01_punjab_education_costs.R`  
**Output Figure:** `figures/punjab_spending_distribution.svg`

### Summary Statistics

- **Total students:** [Enter result]
- **Unweighted median:** Rs [Enter result]
- **Weighted median:** Rs [Enter result]
- **Weighted P10:** Rs [Enter result]
- **Weighted P90:** Rs [Enter result]
- **P90/P10 ratio:** [Enter result]
- **Excluded observations:** [Enter result]

## Question 3 — Gender Differences in Literacy Across Age Groups

### Overview

This analysis examines literacy differences between males and females in rural Punjab. Individuals aged 10–64 were divided into five-year age groups, and literacy rates were calculated using household survey weights.

The graph compares male and female literacy trends and highlights the age group with the largest gender gap.

**Total observations:** 24,630

**R Script:** `scripts/03_gender_literacy_trends.R`  
**Figure:** `figures/punjab_literacy_trends.svg`

### Literacy Rates by Age Group

| Age Group | Male N | Male Literacy (%) | Female N | Female Literacy (%) | Gap (pp) |
|---|---:|---:|---:|---:|---:|
| 10–14 | 2209 | 80.4 | 2133 | 74.5 | 5.9 |
| 15–19 | 1922 | 79.8 | 1758 | 73.1 | 6.7 |
| 20–24 | 1449 | 74.9 | 1574 | 63.1 | 11.8 |
| 25–29 | 1201 | 68.1 | 1386 | 52.9 | 15.2 |
| 30–34 | 1037 | 65.9 | 1176 | 45.4 | 20.5 |
| 35–39 | 1006 | 63.5 | 1194 | 39.6 | 23.9 |
| 40–44 | 843 | 61.3 | 903 | 30.7 | 30.6 |
| 45–49 | 737 | 56.5 | 776 | 25.9 | 30.6 |
| 50–54 | 708 | 52.8 | 657 | 17.6 | 35.2 |
| 55–59 | 517 | 50.8 | 535 | 15.0 |

## Question 4 — From the Default Graph to an Improved Visualization

### Explanation of the Redesign

The original scatterplot displayed individual literacy observations against age, but the large number of overlapping points made it difficult to identify meaningful patterns.

The redesigned graph introduces three important improvements. First, literacy rates are grouped into five-year age intervals, reducing overcrowding and making trends easier to identify. Second, separate lines and direct labels allow male and female literacy rates to be compared without relying on a legend. Third, the largest gender gap is highlighted, drawing attention to an important finding.

Survey-weighted percentages also provide a more meaningful summary of the population than individual binary observations.

However, grouping the data means that individual differences and variation within each age group are no longer visible.

**Original Graph:** `figures/default.svg`  
**Redesigned Graph:** `figures/punjab_literacy_trends.svg`

## Question 5 — Python Verification of Literacy Rates

To check the reliability of the results, the literacy rates for rural Punjab were calculated again using Python. The same age groups, sample restrictions and household weights were used in both R and Python.

**Python Script:** `scripts/04_literacy_validation.py`  
**Figure:** `figures/literacy_python_check.svg`

### Comparison of Results

| Measure | R Result | Python Result |
|---|---|---|
| Total observations | 24,630 | [Enter result] |
| Female literacy (15–19) | 73.1% | [Enter result] |
| Male literacy (15–19) | 79.8% | [Enter result] |
| Largest gender gap | 55–59 | [Enter result] |
| Gap size | 35.8 pp | [Enter result] |

### Method Comparison

R and Python use different functions for grouping and summarizing data.
