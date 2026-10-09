-- 03_partd_pdp_vs_mapd.sql
-- Business question: Standalone PDP vs. MA-PD — where is Part D enrollment
-- actually going?
-- Techniques: aggregation, share of total with window function

SELECT
    year,
    partd_type,          -- 'PDP' or 'MA-PD'
    SUM(enrollment) AS enrollment,
    ROUND(100.0 * SUM(enrollment) / SUM(SUM(enrollment)) OVER (PARTITION BY year), 1) AS share_pct
FROM partd_enrollment
GROUP BY year, partd_type
ORDER BY year, partd_type;
