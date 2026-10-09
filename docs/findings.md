# Findings — Medicare Advantage Star Ratings, 2024 → 2025

Source: CMS Part C and D Star Ratings summary files, 2024 (857 contracts) and
2025 (789 contracts), loaded into SQL Server as `CMS_Stars`. Every number below
comes from a query in `queries/` — the drill ID is in brackets, and its result
screenshot is in `queries/results/`.

## Headline findings

1. **Fewer plans are clearing the 4-star bonus line.** 40.9% of rated contracts
   (213 of 521) earned 4+ stars in 2025, down from 44.4% (242 of 545) in 2024.
   The average rating slipped from 3.68 to 3.65. [B1, dashboard page 1]
2. **Nearly a quarter of 2024's bonus-level contracts lost it.** Of the 242
   contracts at 4+ stars in 2024: 173 (71.5%) held, **56 (23.1%) dropped below 4**,
   9 left the ratings file, 4 went unrated. All four groups reconcile to 242.
   [reconciliation-242]
3. **Kaiser, Alignment and Centene improved the most** among parent organizations
   with 5+ rated contracts — Kaiser 3.79 → **4.29 (+0.50)**, Alignment Healthcare
   3.80 → 4.20 (+0.40), Centene 2.93 → 3.20 (+0.26). [A3, dashboard page 2]
4. **The two largest carriers declined.** UnitedHealth fell 3.94 → 3.76 (−0.18) and
   Humana 3.94 → 3.66 (−0.28); between them they own 11 of the 33 contracts that
   lost a full star or more. [C3]
5. **A third of the 2025 file has no score at all.** 268 of 789 contracts are
   unrated ("too new", "not enough data", "not applicable"). Devoted Health has
   18 of 33 contracts unrated (54.5%); Centene has 18 of 79. [C2]

## By question

### Distribution — where do contracts land? [B1, B2]
- 3.5 stars is the most common 2025 rating: 171 contracts, 32.8% of rated.
- Only 9 contracts reached 5 stars in 2025; 22 sit below 3 stars.

### Year-over-year movement [A1, B4, C3]
- 477 contracts were rated in both years: **113 improved, 199 held flat, 165 declined.**
- 33 dropped by a full star or more. The four steepest (−1.5 stars, 4.5 → 3.0) were
  Martin's Point Generations Advantage, South Country Health Alliance, HealthSpring
  of Florida (Cigna) and Tufts (Point32Health).
- The single biggest gain: Alignment Health Plan (H4961), 3.0 → 4.5 (+1.5).

### Parent organizations [A3, B3]
- Kaiser's +0.50 is the largest improvement among orgs with 5+ rated contracts.
- Leaderboard caveat: the orgs at the top of a pure average (5.0) each have one or
  two contracts. The dashboard leaderboard shows all orgs; read it alongside contract counts.
- Method note: Centene's +0.26 compares *all* its rated contracts in each year. Restricted
  to contracts rated in **both** years (drill A3), the change is +0.17 — still an
  improvement, but smaller. Both are correct; they answer slightly different questions.

### Market entry and exit [A2, A4]
- 101 contracts in the 2024 file are gone from 2025.
- 33 contracts are new in 2025, and none has a rating yet. Devoted Health alone
  launched 9 of them.

### At-risk watch list [C4, dashboard page 3]
- **28 contracts lost ≥1 star** and are still at 3+ stars ("Steep Drop").
- **22 contracts are below 3 stars** in 2025 ("Sub-3 Star Risk").
- 369 contracts have no 2025 rating; the dashboard tracks them separately instead of
  counting them as at-risk.
- SQL drill C3 counts 33 steep drops; the dashboard shows 28 because the flag checks
  sub-3 first, and 5 of those 33 fell below 3 stars.

## Limitations

- **Two years only** (2024, 2025). One year of movement isn't a trend yet.
- **Unweighted averages.** Parent-org averages treat every contract equally regardless
  of enrollment; a 500-member contract counts the same as a 500,000-member one.
- **Unrated ≠ zero.** CMS text values are treated as NULL and excluded from averages,
  so a parent org with many unrated contracts can look better or worse than its full book.
- **Contract IDs are the join key.** A contract that was renumbered or consolidated
  between years shows up as one exit plus one new entrant.
- **Overall rating only.** Part C/D summary and domain-level scores (`domain_2025`) are
  loaded but not yet analyzed.
