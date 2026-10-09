-- 10_premium_rating_vs_growth.sql
-- Business question: Is there a relationship between premiums, star ratings,
-- and enrollment growth at the contract level?
-- Techniques: joins, CTEs, bucketing with CASE, correlation-style comparison

WITH contract_stats AS (
    SELECT
        e.contract_id,
        e.year,
        SUM(e.enrollment) AS enrollment,
        AVG(p.monthly_premium) AS avg_premium,
        MAX(r.star_rating) AS star_rating
    FROM enrollment_by_contract e
    LEFT JOIN plan_premiums p
        ON p.contract_id = e.contract_id AND p.year = e.year
    LEFT JOIN star_ratings r
        ON r.contract_id = e.contract_id AND r.year = e.year
    GROUP BY e.contract_id, e.year
),
with_growth AS (
    SELECT
        *,
        100.0 * (enrollment - LAG(enrollment) OVER (
            PARTITION BY contract_id ORDER BY year))
            / NULLIF(LAG(enrollment) OVER (PARTITION BY contract_id ORDER BY year), 0)
            AS yoy_growth_pct
    FROM contract_stats
)
SELECT
    CASE
        WHEN avg_premium = 0 THEN '$0 premium'
        WHEN avg_premium < 25 THEN '$1–24'
        WHEN avg_premium < 50 THEN '$25–49'
        ELSE '$50+'
    END AS premium_bucket,
    CASE
        WHEN star_rating >= 4 THEN '4+ stars'
        WHEN star_rating >= 3 THEN '3–3.5 stars'
        ELSE 'Below 3 stars'
    END AS rating_bucket,
    COUNT(*) AS contracts,
    ROUND(AVG(yoy_growth_pct), 1) AS avg_yoy_growth_pct
FROM with_growth
WHERE yoy_growth_pct IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, 2;
