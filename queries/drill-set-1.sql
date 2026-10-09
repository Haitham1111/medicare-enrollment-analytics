-- drill-set-1.sql -- CMS Stars Drill Queries -- Database: CMS_Stars | Server: .\SQLEXPRESS
-- Requires: 00_setup_views.sql (builds the FactRatings / DimContract views these drills read)
USE CMS_Stars;

-- A1: 2024 vs 2025 Inner Join
SELECT r24.ContractID, dc.ContractName, dc.ParentOrg, r24.OverallRating AS Rating_2024, r25.OverallRating AS Rating_2025, r25.OverallRating - r24.OverallRating AS YoY_Change
FROM FactRatings AS r24
INNER JOIN FactRatings AS r25 ON r24.ContractID=r25.ContractID AND r24.Year=2024 AND r25.Year=2025
INNER JOIN DimContract AS dc ON dc.ContractID=r24.ContractID
ORDER BY YoY_Change DESC;

-- A2: Contract Gaps Anti-Join
SELECT r24.ContractID, dc.ContractName, dc.ParentOrg, r24.OverallRating AS Rating_2024, 'Not Rated 2025' AS Status_2025
FROM FactRatings AS r24 INNER JOIN DimContract AS dc ON dc.ContractID=r24.ContractID
WHERE r24.Year=2024 AND NOT EXISTS (SELECT 1 FROM FactRatings r25 WHERE r25.ContractID=r24.ContractID AND r25.Year=2025)
ORDER BY r24.OverallRating DESC;

-- A3: Parent Org YoY Rollup
SELECT dc.ParentOrg, AVG(r24.OverallRating) AS AvgRating_2024, AVG(r25.OverallRating) AS AvgRating_2025, AVG(r25.OverallRating)-AVG(r24.OverallRating) AS Org_YoY_Change
FROM FactRatings AS r24 INNER JOIN FactRatings AS r25 ON r24.ContractID=r25.ContractID AND r24.Year=2024 AND r25.Year=2025
INNER JOIN DimContract AS dc ON dc.ContractID=r24.ContractID
GROUP BY dc.ParentOrg ORDER BY Org_YoY_Change DESC;

-- A4: New Entrants Join
SELECT r25.ContractID, dc.ContractName, dc.ParentOrg, r25.OverallRating AS Rating_2025
FROM FactRatings AS r25 INNER JOIN DimContract AS dc ON dc.ContractID=r25.ContractID
WHERE r25.Year=2025 AND NOT EXISTS (SELECT 1 FROM FactRatings r24 WHERE r24.ContractID=r25.ContractID AND r24.Year=2024)
ORDER BY r25.OverallRating DESC;

-- B1: Rating Distribution 2025
SELECT OverallRating, COUNT(*) AS ContractCount, CAST(COUNT(*)*100.0/SUM(COUNT(*)) OVER () AS DECIMAL(5,1)) AS PctOfRated
FROM FactRatings WHERE Year=2025 AND OverallRating IS NOT NULL
GROUP BY OverallRating ORDER BY OverallRating;

-- B2: Star Band Distribution HAVING COUNT >= 20
SELECT OverallRating, COUNT(*) AS ContractCount
FROM FactRatings WHERE Year=2025 AND OverallRating IS NOT NULL
GROUP BY OverallRating HAVING COUNT(*) >= 20 ORDER BY OverallRating;

-- B3: Parent Org Avg Rating Top 10
SELECT TOP 10 dc.ParentOrg, COUNT(DISTINCT fr.ContractID) AS ContractCount, AVG(fr.OverallRating) AS AvgRating_2025
FROM FactRatings AS fr INNER JOIN DimContract AS dc ON dc.ContractID=fr.ContractID
WHERE fr.Year=2025 AND fr.OverallRating IS NOT NULL
GROUP BY dc.ParentOrg ORDER BY AvgRating_2025 DESC;

-- B4: YoY Band Migration
SELECT r24.OverallRating AS Band_2024, r25.OverallRating AS Band_2025, COUNT(*) AS ContractsMoved
FROM FactRatings AS r24 INNER JOIN FactRatings AS r25 ON r24.ContractID=r25.ContractID AND r24.Year=2024 AND r25.Year=2025
WHERE r24.OverallRating IS NOT NULL AND r25.OverallRating IS NOT NULL
GROUP BY r24.OverallRating, r25.OverallRating ORDER BY r24.OverallRating, r25.OverallRating;

-- C1: Ranked Contracts per ParentOrg
WITH RankedContracts AS (
  SELECT fr.ContractID, dc.ContractName, dc.ParentOrg, fr.OverallRating,
    ROW_NUMBER() OVER (PARTITION BY dc.ParentOrg ORDER BY fr.OverallRating DESC) AS Rank_Within_Org
  FROM FactRatings AS fr INNER JOIN DimContract AS dc ON dc.ContractID=fr.ContractID
  WHERE fr.Year=2025 AND fr.OverallRating IS NOT NULL
)
SELECT ParentOrg, ContractID, ContractName, OverallRating AS TopRating_2025
FROM RankedContracts WHERE Rank_Within_Org=1 ORDER BY TopRating_2025 DESC;

-- C2: Unrated by ParentOrg
WITH UnratedSummary AS (
  SELECT dc.ParentOrg,
    COUNT(DISTINCT CASE WHEN fr.OverallRating IS NULL THEN fr.ContractID END) AS UnratedCount,
    COUNT(DISTINCT fr.ContractID) AS TotalContracts
  FROM FactRatings AS fr INNER JOIN DimContract AS dc ON dc.ContractID=fr.ContractID
  WHERE fr.Year=2025 GROUP BY dc.ParentOrg
)
SELECT ParentOrg, UnratedCount, TotalContracts, CAST(UnratedCount*100.0/NULLIF(TotalContracts,0) AS DECIMAL(5,1)) AS PctUnrated
FROM UnratedSummary WHERE UnratedCount>0 ORDER BY UnratedCount DESC;

-- C3: Rating Drop Detection
WITH YoYChanges AS (
  SELECT r24.ContractID, dc.ContractName, dc.ParentOrg, r24.OverallRating AS Rating_2024, r25.OverallRating AS Rating_2025, r25.OverallRating-r24.OverallRating AS YoY_Change
  FROM FactRatings AS r24 INNER JOIN FactRatings AS r25 ON r24.ContractID=r25.ContractID AND r24.Year=2024 AND r25.Year=2025
  INNER JOIN DimContract AS dc ON dc.ContractID=r24.ContractID
  WHERE r24.OverallRating IS NOT NULL AND r25.OverallRating IS NOT NULL
)
SELECT ContractID, ContractName, ParentOrg, Rating_2024, Rating_2025, YoY_Change,
  CASE WHEN YoY_Change<=-1 THEN 'Steep Drop (>=1 Star)' WHEN YoY_Change<0 THEN 'Moderate Drop' ELSE 'Stable/Improved' END AS DropCategory
FROM YoYChanges WHERE YoY_Change<0 ORDER BY YoY_Change ASC;

-- C4: Full YoY At-Risk Classification
WITH LatestYear AS (SELECT MAX(Year) AS MaxYear FROM FactRatings),
YoYBase AS (
  SELECT r_curr.ContractID, dc.ContractName, dc.ParentOrg, r_curr.OverallRating AS CurrentRating, r_prev.OverallRating AS PriorRating, r_curr.OverallRating-r_prev.OverallRating AS YoY_Change
  FROM FactRatings AS r_curr CROSS JOIN LatestYear ly
  INNER JOIN FactRatings AS r_prev ON r_prev.ContractID=r_curr.ContractID AND r_prev.Year=ly.MaxYear-1
  INNER JOIN DimContract AS dc ON dc.ContractID=r_curr.ContractID
  WHERE r_curr.Year=ly.MaxYear AND r_curr.OverallRating IS NOT NULL AND r_prev.OverallRating IS NOT NULL
)
SELECT ContractID, ContractName, ParentOrg, PriorRating, CurrentRating, YoY_Change,
  CASE WHEN CurrentRating<3 THEN 'Sub-3 Star Risk' WHEN YoY_Change<=-1 THEN 'Steep Drop (>=1 Star)' ELSE 'Stable / Performing' END AS AtRiskFlag_SQL
FROM YoYBase ORDER BY YoY_Change ASC, CurrentRating ASC;