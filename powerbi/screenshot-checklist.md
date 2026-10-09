# Screenshot Checklist — dashboard exports for the repo

The `.pbix` stays on your machine (large binary, never committed). The repo shows
the work through screenshots in `powerbi/screenshots/`. Export AFTER the cross-page
checklist in `layout-spec.md` is green.

## How to capture

Power BI Desktop has no one-click "page as PNG", so:

1. **Full pages:** **File → Export → Export to PDF** → save, then screenshot each
   page — OR simpler: maximize Power BI Desktop, select the page tab, and use
   **Win + Shift + S** (Snipping Tool) → drag across the full canvas → save.
2. **Spotlight visuals:** click the visual so it's selected (grey border), then
   Win + Shift + S around just that visual — crisper than cropping later.
3. Check each shot: no "(Blank)" categories, titles visible, no cut-off edges.

## Exactly what to export

| # | File name | What | Why |
|---|---|---|---|
| 1 | `page-1-rating-overview.png` | Full Page 1 | Distribution + leaderboard = the headline |
| 2 | `page-2-yoy-movers.png` | Full Page 2 | The improvement story (Kaiser, Alignment, Centene) |
| 3 | `page-3-at-risk-watch.png` | Full Page 3 | The watch list = the analyst's value-add |
| 4 | `spotlight-org-leaderboard.png` | Page 1, visual 1.3 only | Close-up for the README — orgs + YoY bars |
| 5 | `spotlight-movers-table.png` | Page 2, visual 2.2 only | Close-up for the README — top improvers |

## Naming rules

- Lowercase, hyphens, exactly as above — the README links to these paths.
- PNG only. If a file exceeds ~1 MB, re-snip tighter (visual-only) instead of compressing.
- Never commit a screenshot with real-looking but wrong numbers: if drill 6's
  re-run changes Kaiser's value, re-snip Page 2 before committing.

## Where they go

```
powerbi/
  screenshots/
    page-1-rating-overview.png
    page-2-yoy-movers.png
    page-3-at-risk-watch.png
    spotlight-org-leaderboard.png
    spotlight-movers-table.png
```

Send them via Drive (like the ZIPs) or drop them straight into that folder —
either way, they get committed and the README gallery goes live.

## Done-when

- [ ] All 5 files exist in `powerbi/screenshots/` with the exact names above
- [ ] Each opens cleanly — titles readable, no blank categories, numbers match SSMS
- [ ] Page 2 shots reflect the final (re-run) Kaiser number
- [ ] Committed + pushed — README gallery updated
