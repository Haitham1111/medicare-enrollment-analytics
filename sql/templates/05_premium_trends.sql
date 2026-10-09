-- 05_premium_trends.sql
-- Business question: How have average monthly premiums trended by plan type?
-- Techniques: aggregation, LAG() for YoY change
-- Note: use enrollment-weighted averages, not simple averages.

WITH premiums AS (
    SELECT
        year,
        plan_type,
        SUM(monthly_premium * enrollment) / NULLIF(SUM(enrollment), 0) AS weighted_avg_premium
    FROM plan_premiums
    GROUP BY year, plan_type
)
SELECT
    year,
    plan_type,
    ROUND(weighted_avg_premium, 2) AS weighted_avg_premium,
    ROUND(weighted_avg_premium - LAG(weighted_avg_premium) OVER (
        PARTITION BY plan_type ORDER BY year), 2) AS yoy_change
FROM premiums
ORDER BY plan_type, year;
