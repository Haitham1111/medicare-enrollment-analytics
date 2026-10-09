-- reconciliation-242.sql -- NULL-aware 2025 status of every contract that was 4+ stars in 2024
-- Database: CMS_Stars | Server: .\SQLEXPRESS | Requires: 00_setup_views.sql
--
-- Business question: of the 242 contracts sitting at or above the 4-star bonus line in 2024,
-- how many kept it, how many fell below it, and how many vanished from the ratings entirely?
-- A plain INNER JOIN silently drops the last two groups, so this uses LEFT JOIN + explicit
-- NULL handling. The four statuses must add back to 242.

USE CMS_Stars;
GO

WITH Bonus2024 AS (
    SELECT ContractID, OverallRating AS Rating_2024
    FROM dbo.FactRatings
    WHERE [Year] = 2024 AND OverallRating >= 4
),
Status2025 AS (
    SELECT b.ContractID,
           b.Rating_2024,
           r25.OverallRating AS Rating_2025,
           CASE
               WHEN r25.ContractID IS NULL     THEN 'Not in 2025 file'
               WHEN r25.OverallRating IS NULL  THEN 'Unrated in 2025'
               WHEN r25.OverallRating < 4      THEN 'Dropped below 4'
               ELSE                                 'Still 4+'
           END AS Status_2025
    FROM Bonus2024 AS b
    LEFT JOIN dbo.FactRatings AS r25
        ON r25.ContractID = b.ContractID AND r25.[Year] = 2025
)
SELECT Status_2025,
       COUNT(*)                                             AS Contracts,
       CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,1)) AS PctOf242
FROM Status2025
GROUP BY Status_2025
UNION ALL
SELECT 'TOTAL (must equal 242)', COUNT(*), 100.0
FROM Status2025
ORDER BY Contracts DESC;
