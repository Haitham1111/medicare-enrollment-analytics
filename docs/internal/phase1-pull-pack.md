# Phase 1 Pull Pack — exact CMS downloads

Prepared Oct 5, 2026. All links verified live today. Downloads go into
`data/raw/` (git-ignored). Plan: December snapshot per year, 2020–2025.

## 1. Plan-level enrollment (CPSC) — 6 files

Page: https://www.cms.gov/data-research/statistics-trends-and-reports/medicare-advantagepart-d-contract-and-enrollment-data/monthly-enrollment-contract/plan/state/county

Click the rows for report periods **2020-12, 2021-12, 2022-12, 2023-12,
2024-12, 2025-12**. Each downloads a ZIP of CSV (contract × plan × state ×
county).

Gotcha: CMS masks any plan with fewer than 11 enrollees in a month/county.
Plan-level rows will NOT sum to the true county total. This is expected —
use dataset 3 (county totals) for the Phase 2 validation gate, not CPSC sums.

## 2. Star Ratings — 6 files

Page: https://www.cms.gov/Medicare/Prescription-Drug-Coverage/PrescriptionDrugCovGenIn/PerformanceData.html

Downloads section, grab these ZIPs:
- "2020 Star Ratings and Display Measures (ZIP)"
- "2021 Star Ratings and Display Measures (ZIP)"
- "2022 Star Ratings and Display Measures (ZIP)"
- "2023 Star Ratings and Display Measures (ZIP)"
- "2024 Star Ratings Data Tables (Jul 2 2024) (ZIP)"
- "2025 Star Ratings Data Tables (ZIP)"

Grain is contract-level (not plan-level) — joining plan-level enrollment to
contract-level ratings is correct. Column names change between years; the
field you want is the overall/summary rating per contract.

## 3. County enrollment totals — Original Medicare vs MA denominators

Page: https://data.cms.gov/summary-statistics-on-beneficiary-enrollment/medicare-and-medicaid-reports/medicare-monthly-enrollment

County-level rows include: Total Medicare, Original Medicare, MA/Other Health
Plans, Part D PDP, Part D MA-PD. Filter to December rows 2020–2025. Also
available via the data.cms.gov API on the same page.

## 4. Plan premiums — Landscape files, 2020–2025

Page: https://www.cms.gov/medicare/coverage/prescription-drug-coverage →
downloads section, pick the landscape source file for each year 2020–2025.

Heads-up: starting CY 2025 CMS merged the five landscape files into ONE
combined file (CSV + Excel versions, renamed columns). Memo:
https://www.cms.hhs.gov/files/document/cy2025-landscape-format-memo-20240919.pdf

Current-year shortcut (2026 landscape only): public Socrata API, no key —
`https://data.cms.gov/resource/jfhb-kvhx.json` (one row per plan × county).
Secondary source; fine for spot checks, not the 2020–2024 series.

## 5. SNP enrollment — no extra download

SNP rows are inside dataset 1 (CPSC): filter on the plan-type field for
SNP plan types. Cross-check counts against the landscape files' SNP folder
if something looks off.

## If you get stuck

The imccart/medicare-advantage repo (actively maintained, scripts compile
through 2026) documents every file above and has working R/Stata cleaners:
https://github.com/imccart/medicare-advantage/blob/HEAD/README.md

## After downloading

1. Unzip into `data/raw/`, one folder per dataset.
2. Log row counts + column names in `data/raw/FILE-NOTES.md`
   (watch for: FIPS vs county names, plan_id format changes ~2023, landscape
   column renames in 2025).
3. Say the word — the load scripts (`stg_*` tables) get written next.
