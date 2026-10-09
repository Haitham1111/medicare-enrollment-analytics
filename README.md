# Medicare Advantage Star Ratings Analytics

A healthcare analytics project tracking **CMS Medicare Advantage / Part D star ratings
from 2024 to 2025** — which contracts and parent organizations improved, which fell
below the 4-star bonus line, and which ones disappeared from the ratings entirely.
Built in **SQL Server** and **Power BI** by a licensed Medicare agent who sells these
plans and wanted to see the numbers behind them.

![Rating distribution](powerbi/screenshots/01_rating_distribution.png)

## Headline findings

- **The 4-star bonus line is getting harder to hold.** 44.4% of rated contracts were
  at 4+ stars in 2024; in 2025 it's **40.9%** (213 of 521). Average rating slipped
  from 3.68 to **3.65**.
- **Of the 242 contracts at 4+ stars in 2024, 56 (23%) fell below 4** in 2025 —
  a bonus-payment loss for each. 173 held on, 9 left the ratings file, 4 went unrated.
- **Kaiser (+0.50), Alignment Healthcare (+0.40) and Centene (+0.26)** are the top
  three improvers among parent orgs with 5+ rated contracts. Kaiser now averages 4.29.
  The two biggest carriers went the other way: UnitedHealth −0.18, Humana −0.28.
- **33 contracts dropped a full star or more**; Humana (6) and UnitedHealth (5)
  account for a third of them.
- **Rating coverage is a story of its own:** only 521 of 789 contracts in the 2025
  file have a score. Devoted Health has 54.5% of its contracts unrated.

Full write-up with the query behind every number: [`docs/findings.md`](docs/findings.md).

## Dashboard

Three pages, dark theme, star-rating color rules (green ≥ 4.5 → red < 3.0).

| Page | What it answers |
|---|---|
| ![](powerbi/screenshots/01_rating_distribution.png) **Rating Distribution** | Where do contracts land, and which organizations lead? |
| ![](powerbi/screenshots/02_yoy_movers.png) **Year-over-Year Movers** | Who gained and who lost the most, 2024 → 2025? |
| ![](powerbi/screenshots/03_at_risk_monitoring.png) **At-Risk Monitoring** | Which contracts need attention — steep drops and sub-3-star plans? |

## SQL

Twelve drills on the `CMS_Stars` database (JOINs, anti-joins, GROUP BY / HAVING,
CTEs, window functions) plus a NULL-aware reconciliation query. Every query was run
against the real CMS data — result screenshots are in
[`queries/results/`](queries/results/).

| Block | Drills | Technique |
|---|---|---|
| A — Joins | A1 inner join, A2 anti-join, A3 org rollup, A4 new entrants | `INNER JOIN`, `NOT EXISTS` |
| B — Aggregation | B1–B4 distributions, top orgs, band migration | `GROUP BY`, `HAVING`, `SUM() OVER ()` |
| C — CTEs | C1 ranked contracts, C2 unrated by org, C3 drop detection, C4 at-risk flag | `WITH`, `ROW_NUMBER() OVER (PARTITION BY …)`, `CASE` |
| D — Reconciliation | 242-contract status check | `LEFT JOIN` + explicit NULL handling |

## Project structure

```
├── queries/
│   ├── 00_setup_views.sql        # FactRatings / DimContract views over the raw CMS imports
│   ├── drill-set-1.sql           # the 12 drills
│   ├── reconciliation-242.sql    # NULL-aware status of every 2024 4+ star contract
│   └── results/                  # SSMS screenshots of each query's output
├── powerbi/
│   ├── medicare-star-ratings-dashboard.pbix  # the dashboard — data model + DAX
│   ├── medicare-theme-dark.json  # custom report theme (light variant alongside)
│   ├── dax-measures.md           # every measure and calculated column
│   ├── layout-spec.md            # page-by-page visual spec
│   └── screenshots/              # dashboard pages
├── docs/findings.md              # the write-up
├── data/README.md                # where to download the CMS files
└── sql/templates/                # next phase: enrollment-trend query templates
```

## How to run

1. Download the 2024 and 2025 **Part C and D Star Ratings** data from CMS
   (see [`data/README.md`](data/README.md)) and import the summary and domain sheets
   into a SQL Server database named `CMS_Stars` as `summary_2024`, `summary_2025`,
   `domain_2025`.
2. Run `queries/00_setup_views.sql` once — it builds the `FactRatings` / `DimContract`
   views the drills and the dashboard both use.
3. Run `queries/drill-set-1.sql` and `queries/reconciliation-242.sql`.
4. Open `powerbi/medicare-star-ratings-dashboard.pbix` in Power BI Desktop to inspect the
   model and DAX. To rebuild from scratch, follow `powerbi/dax-measures.md` and
   `powerbi/layout-spec.md`, then import `powerbi/medicare-theme-dark.json` via
   **View → Themes → Browse for themes**.

## Data notes

- CMS publishes text instead of a score for some contracts ("Plan too new to be
  measured", "Not enough data available", "Not Applicable"). These are treated as
  **NULL / unrated**, never as zero, and are counted separately.
- Parent-org averages are simple averages across that org's rated contracts —
  not enrollment-weighted.

## Tech stack

SQL Server (T-SQL) · SSMS · Power BI Desktop · DAX · Power Query

## Author

**Haitham Saleh** — Licensed Medicare insurance agent (top producer) transitioning into healthcare data analytics. Microsoft Certified: Power BI Data Analyst Associate (PL-300).

- LinkedIn: https://www.linkedin.com/in/haitham-saleh-8a1a12206
- GitHub: https://github.com/Haitham1111
