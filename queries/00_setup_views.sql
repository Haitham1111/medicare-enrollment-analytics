-- 00_setup_views.sql -- run once before drill-set-1.sql
-- Database: CMS_Stars | Server: .\SQLEXPRESS
--
-- The raw CMS imports (summary_2024, summary_2025) store one row per contract per file,
-- with the overall rating as text ("4.5", "Plan too new to be measured", "Not Applicable"...).
-- These two views reshape them into the same star schema the Power BI model uses,
-- so every drill reads FactRatings / DimContract exactly like the dashboard does.

USE CMS_Stars;
GO

-- FactRatings: one row per contract per year. OverallRating is NULL when CMS published
-- text instead of a score (too new, not enough data, not applicable).
CREATE OR ALTER VIEW dbo.FactRatings AS
SELECT LTRIM(RTRIM(Contract_Number))              AS ContractID,
       2024                                       AS [Year],
       TRY_CAST(_2024_Overall AS DECIMAL(3,1))    AS OverallRating
FROM dbo.summary_2024
UNION ALL
SELECT LTRIM(RTRIM(Contract_Number)),
       2025,
       TRY_CAST(_2025_Overall AS DECIMAL(3,1))
FROM dbo.summary_2025;
GO

-- DimContract: one row per contract seen in either year. Names come from the 2025 file
-- when the contract is still active, otherwise from 2024.
CREATE OR ALTER VIEW dbo.DimContract AS
SELECT COALESCE(LTRIM(RTRIM(s25.Contract_Number)), LTRIM(RTRIM(s24.Contract_Number))) AS ContractID,
       COALESCE(LTRIM(RTRIM(s25.Contract_Name)),   LTRIM(RTRIM(s24.Contract_Name)))   AS ContractName,
       COALESCE(LTRIM(RTRIM(s25.Parent_Organization)), LTRIM(RTRIM(s24.Parent_Organization))) AS ParentOrg
FROM dbo.summary_2025 AS s25
FULL OUTER JOIN dbo.summary_2024 AS s24
    ON LTRIM(RTRIM(s24.Contract_Number)) = LTRIM(RTRIM(s25.Contract_Number));
GO

-- Sanity check: should return 2024 = 857 rows, 2025 = 789 rows, and 521 rated in 2025
-- (matches the "Rated Contracts" card on dashboard page 1).
SELECT [Year], COUNT(*) AS Contracts, COUNT(OverallRating) AS Rated
FROM dbo.FactRatings
GROUP BY [Year]
ORDER BY [Year];
