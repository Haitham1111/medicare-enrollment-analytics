-- 06_star_ratings_share.sql
-- Business question: Do higher star-rated plans gain enrollment share over time?
-- Techniques: joins (enrollment + star ratings), share with window function

WITH rated AS (
    SELECT
        e.year,
        r.star_rating,
        SUM(e.enrollment) AS enrollment
    FROM enrollment_by_contract e
    JOIN star_ratings r
        ON r.year = e.year
       AND r.contract_id = e.contract_id
    GROUP BY e.year, r.star_rating
)
SELECT
    year,
    star_rating,
    enrollment,
    ROUND(100.0 * enrollment / SUM(enrollment) OVER (PARTITION BY year), 1) AS share_pct
FROM rated
ORDER BY year, star_rating;
