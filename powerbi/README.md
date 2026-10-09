# Power BI Dashboard — Medicare Star Ratings

`medicare-star-ratings-dashboard.pbix` is in this folder — download it and open it in Power BI
Desktop to inspect the data model and DAX. This folder also holds everything needed to rebuild
it from scratch and the screenshots that show it.

| File | What it is |
|---|---|
| `medicare-star-ratings-dashboard.pbix` | The dashboard itself (data model, DAX, 3 pages) |
| `build-guide.md` | Step-by-step build, start here |
| `dax-measures.md` | Every measure and calculated column, as they exist in the model |
| `layout-spec.md` | Page-by-page visual spec |
| `screenshot-checklist.md` | How and what to capture |
| `medicare-theme-dark.json` | Custom report theme (the one in use) |
| `medicare-theme-light.json` | Light variant of the same theme |
| `screenshots/` | `01_rating_distribution.png`, `02_yoy_movers.png`, `03_at_risk_monitoring.png` |

## Pages

1. **Rating Distribution** — KPI cards (avg star rating, rated contracts, % at 4+
   stars), Year tiles (2024 / 2025), contracts by star band, and an organization
   leaderboard bar chart colored by star-rating rules (green ≥ 4.5 → red < 3.0).
2. **Year-over-Year Movers** — Top 10 gainers (green) and steepest 10 drops (red) at
   contract level, the full movers table, and a Key Findings callout
   (Kaiser +0.50, Alignment Healthcare +0.40, Centene +0.26).
3. **At-Risk Monitoring** — KPI cards for steep drops, sub-3-star contracts and unrated
   contracts; a risk-status donut; and a watch list with conditional formatting
   (soft red for ratings below 3.0, red / orange flag text).

## Data model

- `FactRatings` — one row per contract per year (2024 and 2025 summary files appended).
  `OverallRating` is numeric; CMS text values ("Plan too new to be measured", etc.) are blank.
- `DimContract` — one row per contract (890), with `ContractName`, `ParentOrg` and the
  calculated `At-Risk Flag`.
- Relationship: `DimContract[ContractID]` 1 → * `FactRatings[ContractID]`, single direction.
- `_Measures` — measure table; see `dax-measures.md`.

The SQL side mirrors this exactly: `queries/00_setup_views.sql` builds `FactRatings` and
`DimContract` views over the same raw tables, so SSMS and the dashboard can be
reconciled number for number.

## Theme

Import with **View → Themes → Browse for themes → `medicare-theme-dark.json`**.
Page background `#0F172A`, card surfaces `#1E293B`, text `#F8FAFC`, and an outer
bottom-right shadow on every visual.
