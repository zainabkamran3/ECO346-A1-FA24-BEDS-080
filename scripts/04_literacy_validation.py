
# Question 5 - Python Verification
# Variant 0: Rural Punjab

from pathlib import Path
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Find the main repository folder
root = Path(__file__).resolve().parent.parent

# Load the original datasets
persons = pd.read_csv(
    root / "data/pslm_person_subset.csv",
    dtype={"hhid": str}
)

households = pd.read_csv(
    root / "data/pslm_hh_subset.csv",
    dtype={"hhid": str}
)

# Merge household details with individual records
survey = persons.merge(
    households[[
        "hhid", "hhweight", "prov_code", "urban_rural"
    ]],
    on="hhid",
    how="inner",
    validate="many_to_one"
)

# Ensure variables are numeric
for column in [
    "prov_code", "urban_rural", "age",
    "sex", "literate", "hhweight"
]:
    survey[column] = pd.to_numeric(
        survey[column], errors="coerce"
    )

# Select rural Punjab and the literacy sample
literacy = survey.loc[
    (survey["prov_code"] == 2) &
    (survey["urban_rural"] == 1) &
    (survey["age"].between(10, 64)) &
    (survey["sex"].isin([1, 2])) &
    (survey["literate"].isin([0, 1])) &
    (survey["hhweight"] > 0) &
    np.isfinite(survey["hhweight"])
].copy()

# Create five-year age groups
age_labels = [
    f"{start}-{start + 4}"
    for start in range(10, 65, 5)
]

literacy["age_band"] = pd.cut(
    literacy["age"],
    bins=np.arange(10, 66, 5),
    labels=age_labels,
    right=False
)

literacy["weighted_lit"] = (
    literacy["literate"] * literacy["hhweight"]
)

print("Total observations:", len(literacy))


# Calculate weighted literacy rates
rates = (
    literacy
    .groupby(["age_band", "sex"], observed=True)
    .agg(
        n=("literate", "size"),
        total_weight=("hhweight", "sum"),
        literate_weight=("weighted_lit", "sum")
    )
    .reset_index()
)

rates["rate"] = (
    100 * rates["literate_weight"] /
    rates["total_weight"]
)

rates["age_mid"] = rates["age_band"].map(
    {label: 12 + i * 5
     for i, label in enumerate(age_labels)}
).astype(float)

# Create the comparison table
male = rates[rates["sex"] == 1][
    ["age_band", "n", "rate"]
].rename(columns={
    "n": "Male_N",
    "rate": "Male_Rate"
})

female = rates[rates["sex"] == 2][
    ["age_band", "n", "rate"]
].rename(columns={
    "n": "Female_N",
    "rate": "Female_Rate"
})

comparison = male.merge(
    female, on="age_band"
).sort_values("age_band")

comparison["Gap_pp"] = (
    comparison["Male_Rate"] -
    comparison["Female_Rate"]
)

print("\nPYTHON LITERACY RESULTS\n")
print(
    comparison.round(1).to_string(index=False)
)

# Find the largest gender gap
largest = comparison.loc[
    comparison["Gap_pp"].abs().idxmax()
]

print("\nLargest gap:", largest["age_band"])
print("Gap:", round(largest["Gap_pp"], 1), "pp")

# Compare female literacy at ages 15-19
female_15_19 = comparison.loc[
    comparison["age_band"] == "15-19",
    "Female_Rate"
].iloc[0]

print(
    "Female literacy (15-19):",
    round(female_15_19, 1), "%"
)
