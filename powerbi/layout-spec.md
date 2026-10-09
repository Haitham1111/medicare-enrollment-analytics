# Layout Spec — 3 Dashboard Pages

Build in order. For each visual: the visual type, exactly what goes in each field
well, and the **insight the page must communicate** — if a viewer can't say that
sentence after 30 seconds, the page isn't done.

Global: **View → Page size → 16:9**. Title text box at the top of every page
(Insert → Text box), 20pt bold. One slicer style everywhere.

> **[uncertain] org column:** the spec uses `DimContract[ParentOrg]`. If your data
> has no parent-org column (confirm in build-guide Step 0), use `ContractName`
> everywhere `ParentOrg` appears — the page still works, just at contract grain.

---

## Page 1 — "Rating Overview"

**The sentence this page must land:** *"Most Medicare Advantage contracts cluster
around 4 stars in 2025, and these are the organizations setting the pace."*

### Visual 1.1 — KPI cards (top row, three across)
- **Visual:** Card (×3).
- **Fields:** `[Avg Star Rating]` · `[Rated Contracts]` · `[% Contracts 4+ Stars]`.
- **Setup:** each card → Format → Values → Decimal places: 2 / 0 / 1.
  Rename the cards (double-click title): "Avg Star Rating (2025)", "Rated Contracts",
  "% at 4+ Stars".
- **Slicer for the row:** Slicer visual → `FactRatings[Year]` → Format → Slicer settings →
  Style: **Tile**, single-select ON. Default it to **2025**.

### Visual 1.2 — Distribution (left, large)
- **Visual:** Clustered column chart.
- **X-axis:** `FactRatings[Star Band]` (already sort-ordered via Star Band Sort).
- **Y-axis:** `[Rated Contracts]`.
- **Title:** "Contracts by star band (2025)".
- **Data labels:** ON (… → Data labels → On).
- **Must show:** where the bulk sits — expect the 4.0–4.4 band to dominate.

### Visual 1.3 — Org leaderboard (right, table)
- **Visual:** Table.
- **Columns, in order:** `ParentOrg` · `[Avg Star Rating]` · `[Rated Contracts]` ·
  `[% Contracts 4+ Stars]` · `[Rating YoY Change]`.
- **Sort:** click the `[Avg Star Rating]` header → descending.
- **Conditional formatting:** select the `[Rating YoY Change]` column in the visual →
  Format → Cell elements → Background color → **Rules**: > 0 green, < 0 red.
  (This is where Kaiser, Alignment Healthcare, and Centene should appear with
  their +0.50 / +0.40 / +0.26 moves — your verified SQL findings, made visual.)
- **Title:** "Organization leaderboard".

**Page 1 done-when:** the three KPI numbers match your SSMS spot-checks, and the
leaderboard shows the same top orgs your drills found.

---

## Page 2 — "Year-over-Year Movers"

**The sentence this page must land:** *"Kaiser, Alignment, and Centene improved the
most — and here are the contracts sliding backwards."*

> **Verified Oct 9:** Kaiser's 2025 average is **4.29** (2024: 3.79). Confirmed by
> drill A3 in SSMS and by the Power BI model — the early 4.75 value was a typo.
> Centene is **+0.26** (2.933 → 3.197); rounding both averages first gives a misleading
> 0.27, so always subtract the unrounded values.

### Visual 2.1 — Callout cards (top row)
- **Visual:** Three Card visuals, or one Text box with the three numbers.
- **Content (your verified findings):**
  - "Kaiser — **+0.50** YoY (highest improvement, 2025 avg 4.29)"
  - "Alignment Healthcare — **+0.40** YoY"
  - "Centene — **+0.26** YoY (still lowest avg, 3.20 — but trending up)"
- These are hand-typed from your SQL results — that's fine, they're your verified numbers.

### Visual 2.2 — Movers table (center, large)
- **Visual:** Table.
- **Columns, in order:** `ContractName` · `ParentOrg` · 2024 rating · 2025 rating ·
  `[Contract YoY Change]`.
  - For the 2024/2025 rating columns: drag `FactRatings[OverallRating]` in twice →
    Filters on this visual → `FactRatings[Year]` → **Basic filtering** → tick 2024
    for the first, 2025 for the second. Rename the columns "2024" and "2025".
- **Sort:** click `[Contract YoY Change]` header → descending (biggest improvers on top).
- **Conditional formatting** on `[Contract YoY Change]`: data bars or red/green rules.

### Visual 2.3 — Top 10 improvers (bottom-left)
- **Visual:** Clustered bar chart.
- **Y-axis:** `ContractName`. **X-axis:** `[Contract YoY Change]`.
- **Filters on this visual:** drag `[Contract YoY Change]` → Filter type: **Top N** →
  Top **10** → By value: `[Contract YoY Change]`.
- **Title:** "Top 10 improvers".

### Visual 2.4 — Bottom 10 decliners (bottom-right)
- Same as 2.3, but **Bottom 10** by `[Contract YoY Change]`.
- **Title:** "Bottom 10 decliners". If any are real names you recognize (Devoted came up
  in your analysis — only include it if your data confirms it), they earn a callout.

**Page 2 done-when:** the movers table sorted desc shows the same top improvers as
your SQL C4 drill, and the Kaiser callout matches the re-run drill-6 number.

---

## Page 3 — "At-Risk Watch"

**The sentence this page must land:** *"These contracts are one bad measure away
from losing stars — this is the watch list."*

### Visual 3.1 — KPI row (top)
- **Visual:** Card (×2).
- **Fields:** `[Dropped Below 4 Count]` → title "Dropped below 4★" ·
  `[Unrated Contracts]` → title "Unrated in 2025".
- Format both as whole numbers, 24pt+.

### Visual 3.2 — Flag breakdown (left)
- **Visual:** Donut chart.
- **Legend:** `DimContract[At-Risk Flag]`.
- **Values:** Count of `DimContract[ContractID]` (drag ContractID → it auto-counts).
- **Title:** "Contracts by risk status".
- **Must show:** the "Dropped below 4" and "Near cutoff (3.5–3.9)" slices — small
  slices here are the whole point of the page.

### Visual 3.3 — Watch-list table (right, large)
- **Visual:** Table.
- **Columns, in order:** `ContractName` · `ParentOrg` · `At-Risk Flag` ·
  2024 rating · 2025 rating (same two-column filter trick as Page 2, visual 2.2).
- **Filters on this visual:** `At-Risk Flag` → **Basic filtering** → tick ONLY:
  "Dropped below 4", "Near cutoff (3.5-3.9)", "Unrated in 2025", "Below 3.5".
  (Exclude "Stable 4+" and "New in 2025" — this table is the watch list, not the phone book.)
- **Sort:** by `At-Risk Flag` ascending, so "Dropped below 4" sits on top.
- **Title:** "Watch list — contracts needing attention".

### Visual 3.4 — Slicer (top-right or above the table)
- **Visual:** Slicer → `DimContract[At-Risk Flag]` → Style: **Dropdown**, multi-select.
  Lets a viewer isolate one flag (e.g. just "Dropped below 4").

**Page 3 done-when:** the "Unrated in 2025" count matches your SSMS re-drill
(the 242-contract status query — "Unrated in 2025" + "Dropped below 4" + "Not in
2025 file" must total 242), and every row in the watch list has a non-blank flag.

---

## Cross-page checklist (before screenshots)

- [ ] Same Year slicer default (2025) behaves identically on pages 1–2
- [ ] No visual shows "(Blank)" as a category — blanks mean a cleaning step was missed
- [ ] All three KPI numbers on Page 1 match SSMS spot-checks
- [x] Kaiser callout on Page 2 matches SSMS drill A3 (4.29, +0.50)
- [ ] Page 3 watch-list counts reconcile with the 242-contract SQL re-drill
- [ ] Every visual has a title; no default "Sum of…" field names visible
