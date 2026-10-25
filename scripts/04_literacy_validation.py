
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
