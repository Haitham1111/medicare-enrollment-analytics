# Medicare Enrollment Analytics

A healthcare data analytics capstone analyzing **Medicare Advantage (Part D / MA-PD) enrollment trends** using CMS public datasets — combining domain expertise from Medicare insurance sales and medical billing with SQL and Power BI.

## Business Questions

1. How has Medicare Advantage enrollment grown relative to Original Medicare over time?
2. Which plan types (HMO, PPO, PFFS) dominate enrollment, and is the mix shifting?
3. Standalone PDP vs. MA-PD: where is Part D enrollment actually going?
4. Which states and counties have the highest MA penetration?
5. How have average monthly premiums trended by plan type?
6. Do higher star-rated plans gain enrollment share over time?
7. Which parent organizations hold the most enrollment (market concentration)?
8. How fast are Special Needs Plans (D-SNP, C-SNP, I-SNP) growing?
9. What do disenrollment and plan-switching patterns look like year over year?
10. Is there a relationship between premiums, star ratings, and enrollment growth?

## Dataset

CMS public use files — **Medicare Advantage / Part D Contract and Enrollment Data**
(see [`data/README.md`](data/README.md) for download links and file descriptions).

Raw data files are **not committed** to this repo (see `.gitignore`).

## Project Structure

```
├── sql/            # Analysis queries (numbered, one business question each)
├── powerbi/        # Dashboard build notes, DAX measures, screenshots
├── data/           # Download instructions only — no raw data committed
└── docs/           # Findings write-up
```

## Techniques Used

- Joins across enrollment, plan characteristics, and ratings files
- CTEs for readable multi-step analysis
- Window functions (`LAG` for YoY growth, `SUM() OVER` for market share, `RANK` for plan rankings)
- Aggregations and pivots for state/county and plan-type breakdowns

## Key Findings

> TODO — fill in as analysis completes. Aim for 4–6 bullet findings a hiring
> manager can skim in 30 seconds, e.g.:
> - MA penetration reached X% nationally in 2025, up from Y% in 2020
> - D-SNP enrollment grew Z% YoY, the fastest-growing segment

See [`docs/findings.md`](docs/findings.md) for the full write-up.

## How to Run

1. Download the CMS files per `data/README.md` into a local `data/raw/` folder (git-ignored).
2. Load into your SQL engine of choice (SQL Server / Postgres / BigQuery).
3. Run queries in `sql/` in numbered order.
4. Open the Power BI notes in `powerbi/` to rebuild the dashboard.

## Tech Stack

SQL · Power BI · DAX · Excel

## Author

**Haitham Saleh** — Licensed Medicare insurance agent (top producer) transitioning into healthcare data analytics. Microsoft Certified: Power BI Data Analyst Associate (PL-300).

- LinkedIn: https://www.linkedin.com/in/haitham-saleh-8a1a12206
- GitHub: https://github.com/Haitham1111
