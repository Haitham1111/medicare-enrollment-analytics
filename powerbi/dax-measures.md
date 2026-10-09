# DAX Measures — Medicare Star Ratings Dashboard

Paste in the order listed (build-guide.md Step 4 has the clicks).
**Measures** go in the `_Measures` table (select it → Table tools → New measure).
**Calculated columns** go on the table named with each one.

All measures are null-safe: unrated contracts (`null` ratings) are excluded from
averages automatically and counted separately. `DIVIDE` is used everywhere instead
of `/` so you never get divide-by-zero errors.

> Naming in this file assumes you renamed things in Power Query exactly as the
> build guide says: fact table `FactRatings` with columns `ContractID`, `Year`,
> `OverallRating`; dimension `DimContract` with `ContractID`, `ContractName`,
> `ParentOrg`. If you named them differently, find-replace before pasting.

---

## Measures (table: `_Measures`)

### Avg Star Rating
```dax
Avg Star Rating =
AVERAGE ( FactRatings[OverallRating] )
```
*What it answers:* the average star rating across whatever is selected (a year, an org, the whole dataset). `AVERAGE` skips nulls, so unrated contracts can't drag it down.

### Rated Contracts
```dax
Rated Contracts =
COUNTROWS (
    FILTER ( FactRatings, NOT ISBLANK ( FactRatings[OverallRating] ) )
)
```
*What it answers:* how many contracts actually have a published rating — the denominator you can defend.

### Unrated Contracts
```dax
Unrated Contracts =
COUNTROWS (
    FILTER ( FactRatings, ISBLANK ( FactRatings[OverallRating] ) )
)
```
*What it answers:* how many contracts have no published rating (the gap Page 3 watches).

### Contracts 4+ Stars
```dax
Contracts 4+ Stars =
COUNTROWS (
    FILTER ( FactRatings, FactRatings[OverallRating] >= 4 )
)
```
*What it answers:* how many contracts hit the 4-star bonus threshold — the number plans get paid on.

### % Contracts 4+ Stars
```dax
% Contracts 4+ Stars =
DIVIDE ( [Contracts 4+ Stars], [Rated Contracts] )
```
*What it answers:* the share of rated contracts at 4+ stars. Format as **%** (Measure tools → Format: Percentage, 1 decimal).

### Rating YoY Change
```dax
Rating YoY Change =
VAR CurrentYear =
    SELECTEDVALUE ( FactRatings[Year] )
VAR CurrentAvg =
    CALCULATE ( [Avg Star Rating], FactRatings[Year] = CurrentYear )
VAR PriorAvg =
    CALCULATE ( [Avg Star Rating], FactRatings[Year] = CurrentYear - 1 )
RETURN
    IF (
        NOT ISBLANK ( CurrentAvg ) && NOT ISBLANK ( PriorAvg ),
        CurrentAvg - PriorAvg
    )
```
*What it answers:* how much the average rating moved versus the prior year, for the current filter context (use with a Year slicer set to 2025). Positive = improving.

### Contract YoY Change
```dax
Contract YoY Change =
VAR LatestYear =
    CALCULATE ( MAX ( FactRatings[Year] ), ALL ( FactRatings[Year] ) )
VAR ThisYearAvg =
    CALCULATE ( AVERAGE ( FactRatings[OverallRating] ), FactRatings[Year] = LatestYear )
VAR LastYearAvg =
    CALCULATE ( AVERAGE ( FactRatings[OverallRating] ), FactRatings[Year] = LatestYear - 1 )
RETURN
    IF (
        NOT ISBLANK ( ThisYearAvg ) && NOT ISBLANK ( LastYearAvg ),
        ThisYearAvg - LastYearAvg
    )
```
*What it answers:* per-contract year-over-year movement — the engine of the Page 2 movers table. Drop it in a table visual with `DimContract[ContractName]` and sort descending to see your biggest improvers. Format as **Decimal, 2 places**; add conditional formatting (green positive / red negative).

### Dropped Below 4 Count
```dax
Dropped Below 4 Count =
COUNTROWS (
    FILTER (
        DimContract,
        DimContract[At-Risk Flag] = "Dropped below 4"
    )
)
```
*What it answers:* how many contracts fell under the 4-star line this year — the headline KPI for Page 3. (Needs the `At-Risk Flag` calculated column below.)

---

## Calculated columns

### Star Band (table: `FactRatings` → Table tools → New column)
```dax
Star Band =
SWITCH (
    TRUE (),
    ISBLANK ( FactRatings[OverallRating] ), "Unrated",
    FactRatings[OverallRating] >= 4.5, "4.5 - 5.0",
    FactRatings[OverallRating] >= 4, "4.0 - 4.4",
    FactRatings[OverallRating] >= 3.5, "3.5 - 3.9",
    FactRatings[OverallRating] >= 3, "3.0 - 3.4",
    "Below 3.0"
)
```
*What it answers:* buckets every contract-year into a rating band for the Page 1 distribution chart. After creating it, sort it properly: create a second column `Star Band Sort` below, select `Star Band` → **Column tools → Sort by column → Star Band Sort**.

```dax
Star Band Sort =
SWITCH (
    TRUE (),
    ISBLANK ( FactRatings[OverallRating] ), 6,
    FactRatings[OverallRating] >= 4.5, 1,
    FactRatings[OverallRating] >= 4, 2,
    FactRatings[OverallRating] >= 3.5, 3,
    FactRatings[OverallRating] >= 3, 4,
    5
)
```

### At-Risk Flag (table: `DimContract` → Table tools → New column)
```dax
At-Risk Flag =
VAR R25 =
    LOOKUPVALUE (
        FactRatings[OverallRating],
        FactRatings[ContractID], DimContract[ContractID],
        FactRatings[Year], 2025
    )
VAR R24 =
    LOOKUPVALUE (
        FactRatings[OverallRating],
        FactRatings[ContractID], DimContract[ContractID],
        FactRatings[Year], 2024
    )
RETURN
    SWITCH (
        TRUE (),
        ISBLANK ( R25 ), "Unrated in 2025",
        ISBLANK ( R24 ), "New in 2025",
        R24 >= 4 && R25 < 4, "Dropped below 4",
        R25 >= 3.5 && R25 < 4, "Near cutoff (3.5-3.9)",
        R25 < 3.5, "Below 3.5",
        "Stable 4+"
    )
```
*What it answers:* one plain-English status per contract — the entire logic of Page 3 in a single column. `LOOKUPVALUE` pulls each contract's 2024 and 2025 ratings side by side; `SWITCH(TRUE(), …)` checks the conditions top-down, first match wins.

> Cross-check: the **"Unrated in 2025"** slice should reconcile with your SQL re-drill
> (the 242-contract NULL-aware status query — category counts must total 242).
> If Power BI and SSMS disagree, SSMS wins until you find why.

---

## Quick reference — which measure goes where

| Page | Visual | Measure / column |
|---|---|---|
| 1 | KPI cards | `Avg Star Rating`, `Rated Contracts`, `% Contracts 4+ Stars` |
| 1 | Distribution chart | `Star Band` (axis), `Rated Contracts` (values) |
| 1 | Org leaderboard table | `ParentOrg`, `Avg Star Rating`, `Rated Contracts`, `% Contracts 4+ Stars`, `Rating YoY Change` |
| 2 | Movers table | `ContractName`, `ParentOrg`, 2024/2025 ratings, `Contract YoY Change` |
| 2 | Top-10 improvers/decliners bars | `ContractName` (axis), `Contract YoY Change` (values) + Top-N filter |
| 3 | KPI | `Dropped Below 4 Count`, `Unrated Contracts` |
| 3 | Flag breakdown | `At-Risk Flag` (axis/legend) |
| 3 | Watch-list table | `ContractName`, `ParentOrg`, `At-Risk Flag`, 2024/2025 ratings |
