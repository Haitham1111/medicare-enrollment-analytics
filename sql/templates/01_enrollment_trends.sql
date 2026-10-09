-- 01_enrollment_trends.sql
-- Business question: How has Medicare Advantage enrollment grown relative to
-- Original Medicare over time?
-- Techniques: aggregation, YoY growth with LAG(), CTE
-- Tables: <your enrollment table>

-- TODO: replace table/column names with your loaded CMS data.

WITH yearly AS (
    SELECT
        year,
        SUM(CASE WHEN program = 'MA' THEN enrollment ELSE 0 END) AS ma_enrollment,
        SUM(CASE WHEN program = 'Original Medicare' THEN enrollment ELSE 0 END) AS original_medicare_enrollment,
        SUM(enrollment) AS total_enrollment
    FROM enrollment_by_year
    GROUP BY year
)
SELECT
    year,
    ma_enrollment,
    original_medicare_enrollment,
    ROUND(100.0 * ma_enrollment / total_enrollment, 1) AS ma_penetration_pct,
    ROUND(100.0 * (ma_enrollment - LAG(ma_enrollment) OVER (ORDER BY year))
        / NULLIF(LAG(ma_enrollment) OVER (ORDER BY year), 0), 1) AS ma_yoy_growth_pct
FROM yearly
ORDER BY year;
