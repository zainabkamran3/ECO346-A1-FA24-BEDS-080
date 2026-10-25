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

### Interpretation

[Add a short interpretation based on the actual results, explaining the difference between typical and higher education spending.]
