# queries/

All files run top-to-bottom on the `CMS_Stars` database (`.\SQLEXPRESS`).
Run them in this order:

1. `00_setup_views.sql` — run once. Builds the `FactRatings` and `DimContract` views
   over the raw CMS imports (`summary_2024`, `summary_2025`). Same star schema as the
   Power BI model; non-numeric CMS ratings become NULL.
2. `drill-set-1.sql` — the 12 drills from Oct 8–9: JOINs (A1–A4), GROUP BY / HAVING
   (B1–B4), CTEs and window functions (C1–C4).
3. `reconciliation-242.sql` — NULL-aware 2025 status of the 242 contracts that were
   at 4+ stars in 2024. The four statuses must total 242.

## results/

SSMS screenshots of every query running against `CMS_Stars` — each shows the query,
the result grid, the server/database in the status bar, and the row count.

| File | Query | Rows |
|---|---|---|
| `A1_2024_vs_2025_inner_join.png` | Contracts present in both years | 756 |
| `A2_contract_gaps_anti_join.png` | 2024 contracts missing from 2025 | 101 |
| `A3_parent_org_yoy_rollup.png` | Parent-org YoY change | 180 |
| `A4_new_entrants_join.png` | 2025 contracts new since 2024 | 33 |
| `B1_rating_distribution_2025.png` | 2025 rating distribution | 7 |
| `B2_star_band_distribution_having.png` | Bands with 20+ contracts | 5 |
| `B3_parent_org_avg_rating_top_10.png` | Top 10 orgs by 2025 average | 10 |
| `B4_yoy_band_migration.png` | 2024 → 2025 band migration | 25 |
| `C1_cte_ranked_contracts_per_org.png` | Top contract per org (`ROW_NUMBER`) | 141 |
| `C2_cte_unrated_by_parent_org.png` | Unrated contracts by org | 108 |
| `C3_cte_rating_drop_detection.png` | Every rating drop, categorized | 165 |
| `C4_cte_full_at_risk_classification.png` | At-risk flag for all contracts rated both years | 477 |
| `D1_reconciliation_242.png` | 242-contract reconciliation | 5 |

Rule: name new files by what they answer (`yoy-improvers.sql`, `at-risk-members.sql`)
and add a result screenshot here when the query is final.
