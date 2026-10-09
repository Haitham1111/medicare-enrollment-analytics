-- 08_snp_growth.sql
-- Business question: How fast are Special Needs Plans (D-SNP, C-SNP, I-SNP) growing?
-- Techniques: aggregation, YoY growth with LAG()

WITH snp AS (
    SELECT
        year,
        snp_type,   -- 'D-SNP', 'C-SNP', 'I-SNP'
        SUM(enrollment) AS enrollment
    FROM snp_enrollment
    GROUP BY year, snp_type
)
SELECT
    year,
    snp_type,
    enrollment,
    ROUND(100.0 * (enrollment - LAG(enrollment) OVER (
        PARTITION BY snp_type ORDER BY year))
        / NULLIF(LAG(enrollment) OVER (PARTITION BY snp_type ORDER BY year), 0), 1) AS yoy_growth_pct
FROM snp
ORDER BY snp_type, year;
