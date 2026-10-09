# Data — Download Instructions

Raw CMS files are **not committed** to this repo (large, and redistribution
terms apply). Download them locally into `data/raw/` (git-ignored) and load
into your SQL engine.

## Sources (all free, public use)

1. **Medicare Advantage / Part D Contract and Enrollment Data**
   CMS data portal → search "MA Part D contract enrollment data".
   Monthly enrollment by contract, plan, state, and county.
2. **Medicare Advantage Star Ratings**
   CMS → "Part C and Part D Star Ratings data" — annual contract-level ratings.
3. **Medicare Monthly Enrollment** (for Original Medicare denominators)
   CMS → "Medicare enrollment dashboard" or monthly enrollment reports.

## Suggested local layout

```
data/
└── raw/                  # git-ignored
    ├── ma_enrollment_2020_2025.csv
    ├── partd_enrollment.csv
    ├── star_ratings.csv
    └── medicare_population_by_county.csv
```

## Loading tips

- Keep one table per file; add a `year` column if the file is monthly
  (aggregate or filter to December / annual snapshots consistently).
- Normalize column names to match the query files in `sql/`
  (e.g. `contract_id`, `plan_type`, `parent_organization`, `enrollment`).
- Index/partition on `(year, contract_id)` and `(year, state, county)`.
