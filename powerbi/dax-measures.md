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
*What it answers:* how many contracts fell under the 4-star line this year.

> **Not used on the dashboard.** The final `At-Risk Flag` (below) has no "Dropped below 4"
> value, so this measure returns blank. The 4-star-line question is answered in SQL instead:
> `queries/reconciliation-242.sql` → 56 contracts. Page 3's KPI cards count contracts by
> flag (Steep Drop, Sub-3 Star Risk) plus `Unrated Contracts`.

---

## Calculated columns

> These are the definitions **as they exist in the .pbix** (verified Oct 9 against the
> live model), not the original draft.

### Star Band (table: `FactRatings` → Table tools → New column)
```dax
Star Band =
SWITCH (
    TRUE (),
    ISBLANK ( FactRatings[OverallRating] ), "Unrated",
    FactRatings[OverallRating] >= 4.5, "4.5 - 5.0 Stars",
    FactRatings[OverallRating] >= 3.5, "3.5 - 4.0 Stars",
    FactRatings[OverallRating] >= 3.0, "3.0 Stars",
    "Below 3.0 Stars"
)
```
*What it answers:* buckets every contract-year into a rating band for the Page 1 distribution chart.

### Star Band Sort (table: `FactRatings` → Table tools → New column)
```dax
Star Band Sort =
SWITCH (
    TRUE (),
    ISBLANK ( FactRatings[OverallRating] ), 5,
    FactRatings[OverallRating] >= 4.5, 4,
    FactRatings[OverallRating] >= 3.5, 3,
    FactRatings[OverallRating] >= 3.0, 2,
    1
)
```
*Why it exists:* without it Power BI sorts the band labels alphabetically, which puts
"Below 3.0 Stars" last. Select `Star Band` → **Column tools → Sort by column → Star Band Sort**
so the chart reads low → high: Below 3.0 · 3.0 · 3.5–4.0 · 4.5–5.0.

### At-Risk Flag (table: `DimContract` → Table tools → New column)
```dax
At-Risk Flag =
VAR Rating2024 =
    CALCULATE ( MAX ( FactRatings[OverallRating] ), FactRatings[Year] = 2024 )
VAR Rating2025 =
    CALCULATE ( MAX ( FactRatings[OverallRating] ), FactRatings[Year] = 2025 )
RETURN
    SWITCH (
        TRUE (),
        ISBLANK ( Rating2025 ), "Unrated in 2025",
        Rating2025 < 3.0, "Sub-3 Star Risk",
        NOT ISBLANK ( Rating2024 ) && ( Rating2025 - Rating2024 ) <= -1.0, "Steep Drop (>=1 Star)",
        "Stable / Performing"
    )
```
*What it answers:* one status per contract — the logic behind Page 3. `SWITCH(TRUE(), …)`
checks top-down, first match wins. Current counts: 471 Stable / Performing,
369 Unrated in 2025, 28 Steep Drop, 22 Sub-3 Star Risk (890 total).

> **Why the `ISBLANK` checks matter:** in DAX, `BLANK() < 3.0` is **TRUE**. The first
> version of this column skipped the blank check, so all 369 unrated contracts were
> labeled "Sub-3 Star Risk" (the card read 391 instead of 22). Same trap on the drop
> test: `BLANK() - Rating2024` is negative. SQL drill C4 excludes NULLs explicitly,
> which is how the mismatch was caught.

> Cross-check: `queries/reconciliation-242.sql` — the 242 contracts at 4+ stars in 2024
> split into 173 still 4+, 56 dropped below 4, 9 not in the 2025 file, 4 unrated.
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
| 3 | KPI cards | Count of `DimContract[ContractID]` filtered to each `At-Risk Flag` value, `Unrated Contracts` |
| 3 | Flag breakdown | `At-Risk Flag` (axis/legend) |
| 3 | Watch-list table | `ContractName`, `ParentOrg`, `At-Risk Flag`, 2024/2025 ratings |
