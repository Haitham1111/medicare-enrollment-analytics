-- 09_disenrollment_patterns.sql
-- Business question: What do disenrollment / plan-switching patterns look like
-- year over year?
-- Techniques: CTE, LAG(), conditional aggregation
-- Note: shape this to whatever switching/disenrollment fields your CMS file has.

WITH base AS (
    SELECT
        year,
        contract_id,
        enrollment,
        LAG(enrollment) OVER (PARTITION BY contract_id ORDER BY year) AS prior_year_enrollment
    FROM enrollment_by_contract
)
SELECT
    year,
    COUNT(*) AS contracts,
    SUM(CASE WHEN enrollment < prior_year_enrollment THEN 1 ELSE 0 END) AS contracts_shrinking,
    ROUND(100.0 * SUM(CASE WHEN enrollment < prior_year_enrollment THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 1) AS pct_contracts_shrinking,
    SUM(enrollment) AS total_enrollment
FROM base
WHERE prior_year_enrollment IS NOT NULL
GROUP BY year
ORDER BY year;
