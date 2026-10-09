-- 02_plan_type_mix.sql
-- Business question: Which plan types (HMO, PPO, PFFS) dominate enrollment,
-- and is the mix shifting?
-- Techniques: aggregation, market share with SUM() OVER, CTE

WITH plan_year AS (
    SELECT
        year,
        plan_type,
        SUM(enrollment) AS enrollment
    FROM enrollment_by_plan
    GROUP BY year, plan_type
)
SELECT
    year,
    plan_type,
    enrollment,
    ROUND(100.0 * enrollment / SUM(enrollment) OVER (PARTITION BY year), 1) AS share_pct
FROM plan_year
ORDER BY year, enrollment DESC;
