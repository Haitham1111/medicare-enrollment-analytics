# Medicare Enrollment Analytics — Build Plan

Drafted Oct 4, 2026. Phase 1 starts Mon Oct 5. Work style: Hebsha (Ember) plans and
checks; Claude (API) does the heavy analytical lifting when needed; Haitham reviews
and pushes to GitHub.

Study budget: ~30–60 min/day during the Oct 5–11 blackout study week (after work
hours; weekdays he's on sales calls 7 AM–5 PM). Dentist Mon 10:30 AM, gym Mon/Wed/Fri
5:30 PM — plan around those, not through them.

## Datasets (all free, public-use, CMS)

Download into `data/raw/` (git-ignored). Use **annual snapshots, December of each
year, 2020–2025**. December snapshots keep the year grain consistent; monthly files
would force aggregation choices that muddy YoY comparisons.

| # | File | CMS source page (search term) | Grain | Answers questions |
|---|------|-------------------------------|-------|-------------------|
| 1 | MA/Part D enrollment by contract–plan–state–county | "MA Part D contract enrollment data" | contract × plan × county × year | 1, 2, 4, 7, 9 |
| 2 | Part C & D Star Ratings | "Part C and Part D Star Ratings data" | contract × year | 6, 10 |
| 3 | Medicare Monthly Enrollment / county enrollment reports | "Medicare enrollment dashboard" | county × year | 1, 4 (denominators) |
| 4 | Plan premiums (Landscape / premium files) | "Medicare Advantage plan premiums" | plan × year | 5, 10 |
| 5 | SNP enrollment / special-needs plan data | "SNP enrollment" (subset of #1, tag SNP type) | plan × year | 8 |

Expected sizes: enrollment files are the big ones (county-level, ~tens of MB per
year as CSV). Nothing here needs cloud — SQL Server on his machine handles it.

## Phases

### Phase 0 — Today (Oct 4, ~15 min, review only)
- [ ] Read this plan; say go/no-go in chat.
- [ ] Confirm SQL Server instance is up and you know the connection string you'll use.

### Phase 1 — Acquire + stage (Oct 5–7, ~45 min total)
- [ ] Download datasets 1–5, December snapshots 2020–2025, into `data/raw/`.
- [ ] Eyeball each file: row counts, column names, year coverage. Log anomalies in
      `data/raw/FILE-NOTES.md` (e.g., a plan_id format that changed in 2023).
- [ ] Load raw tables 1:1 into SQL Server (`stg_*` schema). One table per file.
- [ ] Deliverable: raw tables loaded; a one-page `data/raw/FILE-NOTES.md`.
- Haitham does the downloads (browser, ~15 min). I/Claude write the load script
  and inspect the files.

### Phase 2 — Clean + model (Oct 8–9, ~60 min total)
- [ ] Normalize column names to the contract the `sql/` files expect:
      `year, contract_id, plan_id, plan_type, parent_organization, state, county,
      enrollment, monthly_premium, star_rating, snp_type`.
- [ ] Build a small star schema: `dim_contract`, `dim_plan`, `dim_geo`,
      `fact_enrollment`. Keep `stg_*` untouched for reproducibility.
- [ ] **Validation gate (non-negotiable):** total MA enrollment per year must land
      within ±2% of the published CMS figures. If it doesn't, the pipeline is
      wrong — don't "fix it" by adjusting queries.
- [ ] Wire up queries `01`, `04`, `05` against real tables (replace TODOs).
- **Milestone 1 (Fri Oct 9):** validated star schema + 3 real answers with numbers.
  Commit and push: `git commit -m "Milestone 1: data loaded, schema validated"`.

### Phase 3 — Analyze + write up (Oct 12–18, ~45 min/day)
- [ ] Wire up remaining queries `02, 03, 06, 07, 08, 09, 10` against real data.
- [ ] Fill `docs/findings.md`: 4–6 bullets a hiring manager skims in 30 seconds.
- [ ] Update README "Key Findings" with the same bullets.
- [ ] Peer-review pass: run every query twice, sanity-check two numbers against
      published CMS facts (MA penetration ~55% nationally in recent years —
      verify exact figure from the data, don't hard-code).
- **Milestone 2 (Fri Oct 16):** all 10 questions answered; findings written.

### Phase 4 — Dashboard + ship (Oct 19–25)
- [ ] Power BI: one dashboard, 5–6 visuals (enrollment trend, plan-type mix,
      state penetration map, premium trend, star-rating share, top-parent bar).
- [ ] Save DAX measures in `powerbi/notes.md` + a screenshot in `powerbi/`.
- [ ] Repo hygiene: README badges-free, `.gitignore` verified (no raw data),
      commit history reads like a story.
- [ ] Publish: push to github.com/Haitham1111/medicare-enrollment-analytics,
      add the repo link to LinkedIn Featured + resume projects.
- **Milestone 3 (Fri Oct 23):** shipped, public, linked.

## Known pitfalls (from the scaffold review)
- County files use FIPS codes in some years and names in others — normalize to
  (state, county_name) or (fips); pick one and document it.
- Contract vs plan grain: enrollment files are contract×plan; star ratings are
  contract-level. Joining plan-level enrollment to contract-level ratings is
  correct — don't try to force plan-level stars.
- Territories (PR, Guam): include for completeness, exclude from "national"
  totals and say so in findings.
- Premiums: use enrollment-weighted averages, never simple averages
  (query 05 already does this — keep it).

## Done-when
A stranger (hiring manager) opens the GitHub repo and, in 60 seconds, sees: what
question it answers, the data source, 4–6 real findings with numbers, and one
dashboard screenshot. That's the bar.

## How Claude fits
- Heavy lifting (load scripts, query rewrites, Power BI notes, findings draft)
  goes to Claude Sonnet via API, one assignment at a time.
- I check everything against the repo and the validation gate before it reaches
  Haitham. He is never my QC.
