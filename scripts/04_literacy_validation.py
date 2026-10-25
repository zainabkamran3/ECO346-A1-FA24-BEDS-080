
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

# Plot literacy trends using Python
fig, ax = plt.subplots(figsize=(11, 7))

colors = {
    1: "#333333",
    2: "#B07859"
}

for sex, label in [(1, "Male"), (2, "Female")]:
    group = rates[rates["sex"] == sex].sort_values(
        "age_mid"
    )

    ax.plot(
        group["age_mid"],
        group["rate"],
        color=colors[sex],
        linewidth=2
    )

    for _, row in group.iterrows():
        ax.scatter(
            row["age_mid"],
            row["rate"],
            s=48,
            facecolors=(
                "white" if row["n"] < 30
                else colors[sex]
            ),
            edgecolors=colors[sex],
            zorder=3
        )

    # Label the line directly
    last = group.iloc[-1]
    ax.text(
        64, last["rate"], label,
        color=colors[sex],
        fontsize=11,
        fontweight="bold",
        va="center"
    )

# Highlight the largest gender gap
gap_age = (
    12 + age_labels.index(str(largest["age_band"])) * 5
)

ax.vlines(
    gap_age,
    largest["Female_Rate"],
    largest["Male_Rate"],
    colors="gray",
    linestyles="dashed"
)

ax.text(
    0.98, 0.96,
    f"Largest gap: {largest['age_band']}\n"
    f"{largest['Gap_pp']:.1f} percentage points",
    transform=ax.transAxes,
    ha="right",
    va="top",
    fontsize=10
)

ax.set_title(
    "Literacy across age groups in rural Punjab",
    fontsize=15,
    fontweight="bold"
)

ax.set_xlabel("Age group")
ax.set_ylabel("Weighted literacy rate (%)")

ax.set_xticks(list(range(12, 63, 5)))
ax.set_xticklabels(age_labels, rotation=45)

ax.set_xlim(10, 71)
ax.set_ylim(0, 100)
ax.grid(axis="y", alpha=0.2)

fig.text(
    0.10, 0.02,
    "Source: PSLM | Weight: hhweight | "
    "Hollow points indicate N < 30",
    fontsize=9
)

fig.tight_layout(rect=(0, 0.04, 1, 1))

# Save Python figure
output = root / "figures/literacy_python_check.svg"
output.parent.mkdir(exist_ok=True)

fig.savefig(output, format="svg")
plt.show()

print("Python graph saved:", output)
