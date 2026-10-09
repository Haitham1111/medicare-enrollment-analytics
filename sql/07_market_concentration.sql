-- 07_market_concentration.sql
-- Business question: Which parent organizations hold the most enrollment?
-- Techniques: aggregation, RANK(), cumulative share with window function

WITH org AS (
    SELECT
        year,
        parent_organization,
        SUM(enrollment) AS enrollment
    FROM enrollment_by_contract
    GROUP BY year, parent_organization
),
ranked AS (
    SELECT
        year,
        parent_organization,
        enrollment,
        RANK() OVER (PARTITION BY year ORDER BY enrollment DESC) AS org_rank,
        ROUND(100.0 * enrollment / SUM(enrollment) OVER (PARTITION BY year), 1) AS share_pct
    FROM org
)
SELECT
    year,
    parent_organization,
    enrollment,
    share_pct,
    ROUND(SUM(share_pct) OVER (
        PARTITION BY year ORDER BY org_rank
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 1) AS cumulative_share_pct
FROM ranked
WHERE org_rank <= 10
ORDER BY year DESC, org_rank;
