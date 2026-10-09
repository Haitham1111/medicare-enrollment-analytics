# Power BI Build Guide — Medicare Star Ratings Dashboard

Paint-by-numbers. Follow top to bottom; don't skip steps. Estimated time: ~2 hours
for all 3 pages. You build the `.pbix` on your Windows machine in Power BI Desktop —
nothing here needs the repo except the screenshots at the end.

**What you're building:** a 3-page dashboard on CMS Medicare Advantage Star Ratings
(2024–2025) — rating distribution, year-over-year movers, at-risk watch. Your verified
SQL findings (Kaiser +0.50, Alignment +0.40, Centene +0.26) get their own page.

**Prerequisites:** Power BI Desktop installed and open · SQL Server running with the
`CMS_Stars` database loaded (2024 + 2025 Star Ratings tables imported) · the DAX file
`dax-measures.md` open beside you.

> **Why this order:** connect → clean (Power Query) → model → measures (DAX) →
> visuals. Cleaning before modeling is the PL-300 way — a clean star schema makes
> every measure simpler.

---

## Step 0 — Confirm your table and column names (5 min)

I don't know the exact table names you gave your imports in SSMS, so confirm them
first. In SSMS, run:

```sql
SELECT TABLE_SCHEMA, TABLE_NAME
FROM CMS_Stars.INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
```

Then for each ratings table, run `SELECT TOP 3 *` and write down the real names.
Fill in this mapping — everything later in the guide refers to the **Power BI names**
on the right, which you set yourself in Step 2, so the DAX stays exact no matter
what your SQL tables are called:

| What it is | Your SQL table name | Your contract-ID column | Your contract-name column | Your overall-rating column | Your org column (if any) |
|---|---|---|---|---|---|
| 2025 Summary Ratings | | | | (looks like `2025 Overall`) | |
| 2024 Summary Ratings | | | | (looks like `2024 Overall`) | |

**[uncertain]:** the overall-rating columns are probably `2025 Overall` / `2024 Overall`
(that's what the 2025 file carries), and the contract-ID column is probably
`Contract Number` — but **your** `SELECT TOP 3` wins. If there is no parent-organization
column, use Contract Name for the leaderboard instead (the guide flags those spots).

---

## Step 1 — Connect Power BI Desktop to SQL Server (5 min)

1. In Power BI Desktop: **Home → Get Data → SQL Server**.
2. **Server:** type `localhost` and click OK.
   - If that fails with "couldn't connect": your instance is probably named.
     In SSMS, look at the **Server name** in the Connect dialog — it's usually
     `localhost\SQLEXPRESS` or `YOUR-PC-NAME\SQLEXPRESS`. Type exactly that instead.
3. **Database:** type `CMS_Stars` (optional but do it — keeps the Navigator clean).
4. **Data Connectivity mode:** leave on **Import** → OK.
5. If it asks for credentials: left nav **Windows** → **Use my current credentials** → Connect.
6. In the **Navigator** window, tick the checkboxes for your **two ratings tables**
   (2024 + 2025). You should see a preview below.
7. Click **Transform Data** (bottom-right). **Not Load** — we clean first.

You are now in Power Query Editor.

---

## Step 2 — Clean in Power Query (30 min)

Do this for **each** of the two ratings queries (repeat 2a–2d twice).

### 2a. Drop the title row, promote headers

1. With the query selected: **Home → Remove Rows → Remove Top Rows** → `1` → OK.
   (Row 1 is the "2025 Star Ratings" title — the real header is row 2.)
2. **Home → Use First Row as Headers**.
3. In the **Queries** pane (left), right-click the query → **Rename**:
   - the 2025 one → `Ratings2025`
   - the 2024 one → `Ratings2024`

### 2b. Convert the rating columns to real numbers (null-safe)

Rating columns mix numbers with text like `Not Applicable` and
`Not enough data available`. This one formula handles all of it:

1. **Add Column → Custom Column**.
2. **New column name:** `OverallRating`
3. **Formula** (replace `2025 Overall` with YOUR exact column name from Step 0 —
   keep the `#"..."` quotes, they're required for names with spaces):

   ```
   = try Number.From([#"2025 Overall"]) otherwise null
   ```

   > What this does: tries to read the cell as a number; if it's text
   > ("Not Applicable", blank, anything), it writes `null` instead of erroring.

4. Click OK. The new column should show decimals and `null`s — **nulls are correct**,
   they mean "unrated". Do NOT delete null rows; Page 3 needs them.
5. Repeat for Part C and Part D if you want them (names: `PartCRating`,
   `PartDRating`, same pattern with `#"2025 Part C Summary"` / `#"2025 Part D Summary"`).
   Optional — the dashboard only requires Overall.
6. (Optional, keeps things tidy) Right-click the original text rating columns →
   **Remove**. Keep `OverallRating` (+ Part C/D if you made them).

### 2c. Add the Year column

1. **Add Column → Custom Column** → name: `Year` → formula: `2025` (or `2024`
   for the other query) → OK.
2. Select the `Year` column → **Transform → Data Type: Whole Number**.

### 2d. Standardize the key columns

1. Rename your contract-ID column to `ContractID`: right-click the column header → **Rename**.
2. Rename contract-name to `ContractName`, org to `ParentOrg` (if it exists).
3. Select `ContractID` → **Transform → Data Type: Text** (contract IDs like `H1234`
   must stay text, never numbers).

### 2e. Append into one fact table

1. **Home → Append Queries → Append Queries as New**.
2. Select `Ratings2024` and `Ratings2025` → OK.
3. Rename the new query to `FactRatings`.
4. Check: the `Year` column should show both 2024 and 2025. Row count ≈ sum of both.

### 2f. Build the contract dimension

1. In the Queries pane, right-click `FactRatings` → **Reference**. Rename to `DimContract`.
2. Select ONLY `ContractID`, `ContractName`, `ParentOrg` (Ctrl+click) → right-click →
   **Remove Other Columns**.
3. **Home → Remove Rows → Remove Duplicates**. One row per contract now.
4. Click **Home → Close & Apply** (top-left). Power BI loads the model.

---

## Step 3 — Model view: relationships and settings (10 min)

1. Click **Model view** (left sidebar, third icon).
2. Drag `DimContract[ContractID]` and drop it on `FactRatings[ContractID]`.
   - Double-click the relationship line: **Cardinality** = Many to one (*:1),
     **Cross-filter direction** = Single (DimContract → FactRatings). OK.
3. Hide the raw key: right-click `FactRatings[ContractID]` → **Hide**.
4. Select `FactRatings[OverallRating]` → **Column tools** ribbon → **Summarization:
   Don't summarize** (we always use measures, never implicit sums).
5. Create the measures table: **Home → Enter Data** → name it `_Measures` →
   keep the dummy column → OK. (All DAX measures will live here — keeps Model view clean.)
   In Model view, right-click the dummy `Column1` → Hide.

---

## Step 4 — Write the DAX (20 min)

Open `dax-measures.md`. For each **measure**:

1. In **Model view** or **Data view**, select the `_Measures` table.
2. **Table tools → New measure**, paste the code, press Enter.
3. For each **calculated column**, select the target table first
   (`FactRatings` for Star Band, `DimContract` for At-Risk Flag),
   then **Table tools → New column**, paste, Enter.

Order: measures first (Avg Star Rating → Rated Contracts → Contracts 4+ Stars →
% Contracts 4+ Stars → Rating YoY Change → Contract YoY Change), then the two
calculated columns. Each one in `dax-measures.md` says what business question it
answers — read that line before pasting, so you know what you just built.

---

## Step 5–7 — Build the 3 pages (45 min)

Open `layout-spec.md` — it gives you every page's visuals, exactly which
field/measure goes where, and the insight each page must communicate.
Build in order: Page 1 → Page 2 → Page 3.

General habits while building:
- Every visual gets a title (double-click the title placeholder).
- KPI cards: **Visualizations → Card** → drag the measure into **Fields**.
- Tables: **Visualizations → Table** → drag columns/measures in the order listed.
- Sort a table by a column: click the column header in the visual (click again to flip).
- Slicer: **Visualizations → Slicer** → drag `FactRatings[Year]` (or `DimContract[At-Risk Flag]`).

---

## Step 8 — Save and screenshot (10 min)

1. **File → Save** → save as `medicare-star-ratings-dashboard.pbix` on your machine
   (Documents or wherever you keep it). **Do NOT put the .pbix in the repo** —
   it's a large binary; the repo gets screenshots only.
2. Follow `screenshot-checklist.md` — export the 3 pages + 2 spotlight visuals,
   save to `powerbi/screenshots/`, then send them my way (Drive, like the ZIPs)
   or drop them straight into the repo folder.
3. Your `queries/drill-set-1.sql` (the 12 drills) lives in `queries/` when you
   send it — the dashboard doesn't block on it, but the repo README will link
   the two together.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `localhost` won't connect | Use the exact Server name from your SSMS Connect dialog (often `localhost\SQLEXPRESS`) |
| Navigator shows no tables | Check the Database field says `CMS_Stars`; check you're looking at Tables, not Views |
| `Number.From` errors on a column | Your column name in the formula doesn't match — re-check Step 0, keep the `#"..."` quotes |
| Ratings show as text after custom column | Select `OverallRating` → Transform → Data Type → Decimal Number |
| Relationship won't create (*:1) | `DimContract` still has duplicates — redo Step 2f.3, or `ContractID` types differ (both must be Text) |
| YoY measure shows blank | The `Year` column must be Whole Number and contain exactly 2024 and 2025 |
| "Not enough data available" variants | The `try…otherwise null` pattern already catches every text variant — no extra step needed |
| Visual shows (Blank) in At-Risk Flag | A contract exists in only one year — that's real, it means "new/dropped"; leave it |
