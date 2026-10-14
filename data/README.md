# Data

Raw CMS files are **not committed** to this repo (large, and redistribution terms apply). Download them locally into `data/raw/` (git-ignored) and load them into SQL Server as described below.

## Sources used (free, public)

**CMS Part C and Part D Star Ratings data tables**, from [CMS Part C and D Performance Data](https://www.cms.gov/medicare/health-drug-plans/part-c-d-performance-data).

| Release | Zip | File used |
|---|---|---|
| 2024 Star Ratings | `2024-star-ratings-data-tables.zip` | `2024 Star Ratings Data Table - Summary Rating (Jul 2 2024).csv` |
| 2025 Star Ratings | `2025-star-ratings-data-tables.zip` | `2025 Star Ratings Data Table - Summary Ratings (Dec 2 2024).csv` and `... - Domain Stars (Dec 2 2024).csv` |

Contract counts: 857 contracts in the 2024 file, 789 in the 2025 file.

## Load

Import into a database named `CMS_Stars` on SQL Server Express as `summary_2024`, `summary_2025` and `domain_2025`, then run [`../sql/00_setup_views.sql`](../sql/00_setup_views.sql) to build `FactRatings` and `DimContract`. Text values CMS publishes instead of a score (for example "Plan too new to be measured") become NULL, never zero.

## Not used yet

The enrollment, premium and market-concentration datasets that the starter files in [`../sql/templates/`](../sql/templates/) describe are **not** loaded in this project. Those templates are scaffolding for a next phase.
