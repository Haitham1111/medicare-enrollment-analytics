# Power BI Dashboard — Build Notes

## Pages

1. **Overview** — KPI cards: total MA enrollment (latest year), MA penetration %,
   YoY growth %. Line chart: MA vs. Original Medicare enrollment over time.
2. **Plan Mix** — Donut: enrollment share by plan type (HMO/PPO/PFFS).
   Stacked bar: plan-type mix by year.
3. **Geography** — Filled map: MA penetration by state. Bar chart: top 10 counties.
   Slicer: year.
4. **Premiums & Ratings** — Line: weighted avg premium by plan type over time.
   Bar: enrollment share by star rating. Scatter: premium vs. enrollment growth
   by contract (ties to `sql/10_premium_rating_vs_growth.sql`).
5. **Market** — Bar: top 10 parent organizations by enrollment. Line: D-SNP/C-SNP/I-SNP
   enrollment growth.

## Data Model

- Fact: enrollment (one row per contract × year, or county × year)
- Dimensions: date/year, geography (state/county), plan (contract, plan type,
  parent org), ratings
- Relationships: single-direction, star schema. Hide key columns used only for joins.

## DAX Measures to Write

```dax
Total Enrollment = SUM ( Enrollment[enrollment] )

MA Penetration % =
DIVIDE (
    CALCULATE ( [Total Enrollment], Enrollment[program] = "MA" ),
    [Total Enrollment]
)

YoY Growth % =
VAR CurrentYear = [Total Enrollment]
VAR PriorYear =
    CALCULATE ( [Total Enrollment], SAMEPERIODLASTYEAR ( 'Date'[Date] ) )
RETURN
    DIVIDE ( CurrentYear - PriorYear, PriorYear )

Weighted Avg Premium =
DIVIDE (
    SUMX ( Premiums, Premiums[monthly_premium] * Premiums[enrollment] ),
    SUM ( Premiums[enrollment] )
)
```

## Screenshots

Export each dashboard page as PNG and drop it here (`page-1-overview.png`, …)
so the repo shows the work without requiring the .pbix to open.
