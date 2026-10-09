-- 04_geographic_penetration.sql
-- Business question: Which states and counties have the highest MA penetration?
-- Techniques: joins (enrollment + total medicare population), RANK()

WITH geo AS (
    SELECT
        e.year,
        e.state,
        e.county,
        SUM(e.enrollment) AS ma_enrollment,
        p.total_medicare_beneficiaries
    FROM ma_enrollment_by_county e
    JOIN medicare_population_by_county p
        ON p.year = e.year
       AND p.state = e.state
       AND p.county = e.county
    GROUP BY e.year, e.state, e.county, p.total_medicare_beneficiaries
)
SELECT
    year,
    state,
    county,
    ma_enrollment,
    ROUND(100.0 * ma_enrollment / NULLIF(total_medicare_beneficiaries, 0), 1) AS penetration_pct,
    RANK() OVER (PARTITION BY year, state ORDER BY
        100.0 * ma_enrollment / NULLIF(total_medicare_beneficiaries, 0) DESC) AS county_rank_in_state
FROM geo
ORDER BY year DESC, penetration_pct DESC;
