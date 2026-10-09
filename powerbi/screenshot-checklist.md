# Screenshot Checklist — dashboard exports for the repo

The `.pbix` is committed at `powerbi/medicare-star-ratings-dashboard.pbix`. The screenshots in
`powerbi/screenshots/` and SQL result screenshots in `queries/results/` let people see the work
without opening Power BI.
Export AFTER the cross-page checklist in `layout-spec.md` is green.

## How to capture

1. Maximize Power BI Desktop and collapse the Filters, Visualizations and Data panes
   so the canvas fills the window.
2. Select the page tab, move the mouse off the canvas (no hover tooltips), then
   **Win + Shift + S** → drag across the full canvas → save as PNG.
3. Check each shot: no "(Blank)" categories, titles visible, no cut-off edges,
   no visual left selected or cross-highlighted.

## Exactly what to export

| # | File name | Tab name in the .pbix | What it shows |
|---|---|---|---|
| 1 | `01_rating_distribution.png` | Rating Distribution | KPI cards, star-band distribution, star-colored org leaderboard |
| 2 | `02_yoy_movers.png` | Year-over-Year Movers | Green gainers / red drops, all-movers table, Key Findings callout |
| 3 | `03_at_risk_monitoring.png` | At-Risk Monitoring | Risk KPI cards, risk-status donut, conditionally formatted watch list |

## Naming rules

- Exactly as above — two-digit page number, underscore, lowercase. The README links to these paths.
- PNG only. If a file exceeds ~1 MB, re-snip tighter instead of compressing.
- Never commit a screenshot whose numbers disagree with SSMS. The Key Findings callout
  on page 2 must read Kaiser +0.50, Alignment +0.40, Centene +0.26.

## Where they go

```
powerbi/
  screenshots/
    01_rating_distribution.png
    02_yoy_movers.png
    03_at_risk_monitoring.png
queries/
  results/
    A1_… through D1_….png   # one per query, see queries/README.md
```

## Done-when

- [x] All 3 dashboard files exist in `powerbi/screenshots/` with the exact names above
- [x] All 13 SQL result screenshots exist in `queries/results/`
- [x] Numbers match SSMS (521 rated, 3.65 avg, 40.9% at 4+, Kaiser 4.29)
- [ ] Committed + pushed — README gallery live
