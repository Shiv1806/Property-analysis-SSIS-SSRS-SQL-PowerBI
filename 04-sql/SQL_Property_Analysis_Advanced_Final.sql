/*
PROJECT: Property Analysis BI Developer

*/


------------------------------------------------------------
-- 01. STATE MARKET SNAPSHOT
------------------------------------------------------------
SELECT
    g.State,
    COUNT(*) AS Records,
    AVG(f.House_Value) AS Avg_House_Value,
    MIN(f.House_Value) AS Min_House_Value,
    MAX(f.House_Value) AS Max_House_Value,
    AVG(f.Rental_Amount) AS Avg_Rental_Amount,
    AVG(CAST(f.Recorded_Incidents AS decimal(18,2))) AS Avg_Recorded_Incidents
FROM Fact_Table_Advance f
JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
GROUP BY g.State
ORDER BY Avg_House_Value DESC;


------------------------------------------------------------
-- 02. STATE RANKING BY AVERAGE HOUSE VALUE
------------------------------------------------------------
WITH StateMarket AS
(
    SELECT
        g.State,
        AVG(f.House_Value) AS Avg_House_Value
    FROM Fact_Table_Advance f
    JOIN Dim_Geography_Data g
        ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
    WHERE f.House_Value IS NOT NULL
    GROUP BY g.State
)
SELECT
    State,
    Avg_House_Value,
    DENSE_RANK() OVER (ORDER BY Avg_House_Value DESC) AS State_Rank
FROM StateMarket
ORDER BY State_Rank;


------------------------------------------------------------
-- 03. TOP 20 SUBURBS BY AVERAGE HOUSE VALUE
------------------------------------------------------------
SELECT TOP (20)
    g.State,
    g.City,
    g.Suburb,
    AVG(f.House_Value) AS Avg_House_Value,
    COUNT(*) AS Records
FROM Fact_Table_Advance f
JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
WHERE f.House_Value IS NOT NULL
  AND g.Suburb IS NOT NULL
GROUP BY g.State, g.City, g.Suburb
ORDER BY Avg_House_Value DESC, Records DESC;


------------------------------------------------------------
-- 04. TOP 20 SUBURBS BY AVERAGE RENTAL AMOUNT
------------------------------------------------------------
SELECT TOP (20)
    g.State,
    g.City,
    g.Suburb,
    AVG(f.Rental_Amount) AS Avg_Rental_Amount,
    COUNT(*) AS Records
FROM Fact_Table_Advance f
JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
WHERE f.Rental_Amount IS NOT NULL
  AND g.Suburb IS NOT NULL
GROUP BY g.State, g.City, g.Suburb
ORDER BY Avg_Rental_Amount DESC, Records DESC;


------------------------------------------------------------
-- 05. HOUSE VALUE SEGMENTATION
------------------------------------------------------------
SELECT
    CASE
        WHEN f.House_Value < 300000 THEN 'Below 300K'
        WHEN f.House_Value < 500000 THEN '300K-499K'
        WHEN f.House_Value < 750000 THEN '500K-749K'
        WHEN f.House_Value < 1000000 THEN '750K-999K'
        ELSE '1M+'
    END AS House_Value_Band,
    COUNT(*) AS Records,
    AVG(f.House_Value) AS Avg_House_Value
FROM Fact_Table_Advance f
WHERE f.House_Value IS NOT NULL
GROUP BY
    CASE
        WHEN f.House_Value < 300000 THEN 'Below 300K'
        WHEN f.House_Value < 500000 THEN '300K-499K'
        WHEN f.House_Value < 750000 THEN '500K-749K'
        WHEN f.House_Value < 1000000 THEN '750K-999K'
        ELSE '1M+'
    END
ORDER BY MIN(f.House_Value);



------------------------------------------------------------
-- 06. VALUE RANGE BY STATE
------------------------------------------------------------
SELECT
    g.State,
    MIN(f.House_Value) AS Min_House_Value,
    MAX(f.House_Value) AS Max_House_Value,
    MAX(f.House_Value) - MIN(f.House_Value) AS House_Value_Range,
    AVG(f.House_Value) AS Avg_House_Value
FROM Fact_Table_Advance f
JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
WHERE f.House_Value IS NOT NULL
GROUP BY g.State
ORDER BY House_Value_Range DESC;



------------------------------------------------------------
-- 07. CITY-LEVEL MARKET COMPARISON
------------------------------------------------------------
SELECT
    g.State,
    g.City,
    COUNT(DISTINCT g.Suburb) AS Distinct_Suburbs,
    AVG(f.House_Value) AS Avg_House_Value,
    AVG(f.Rental_Amount) AS Avg_Rental_Amount,
    AVG(CAST(f.Recorded_Incidents AS decimal(18,2))) AS Avg_Recorded_Incidents
FROM Fact_Table_Advance f
JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
GROUP BY g.State, g.City
ORDER BY Avg_House_Value DESC;


------------------------------------------------------------
-- 08. PROPERTY / GEOGRAPHY JOIN VALIDATION
------------------------------------------------------------
SELECT
    COUNT(*) AS Fact_Rows,
    COUNT(g.Dim_Geography_Data_Key) AS Geography_Matched_Rows,
    COUNT(*) - COUNT(g.Dim_Geography_Data_Key) AS Unmatched_Geography_Rows
FROM Fact_Table_Advance f
LEFT JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key;


------------------------------------------------------------
-- 09. GEOGRAPHY DATA QUALITY
------------------------------------------------------------
SELECT
    COUNT(*) AS Total_Geography_Rows,
    SUM(CASE WHEN State IS NULL OR LTRIM(RTRIM(State)) = '' THEN 1 ELSE 0 END) AS Missing_State,
    SUM(CASE WHEN City IS NULL OR LTRIM(RTRIM(City)) = '' THEN 1 ELSE 0 END) AS Missing_City,
    SUM(CASE WHEN Suburb IS NULL OR LTRIM(RTRIM(Suburb)) = '' THEN 1 ELSE 0 END) AS Missing_Suburb,
    SUM(CASE WHEN Latitude IS NULL THEN 1 ELSE 0 END) AS Missing_Latitude,
    SUM(CASE WHEN Longitude IS NULL THEN 1 ELSE 0 END) AS Missing_Longitude
FROM Dim_Geography_Data;




------------------------------------------------------------
-- 10. SCHOOL COVERAGE BY STATE
------------------------------------------------------------
SELECT
    g.State,
    COUNT(DISTINCT s.Dim_School_Data_Key) AS School_Record_Count,
    COUNT(DISTINCT s.School_Name) AS Distinct_School_Names
FROM Fact_Table_Advance f
JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
JOIN Dim_School_Data s
    ON f.Dim_School_Data_Key = s.Dim_School_Data_Key
GROUP BY g.State
ORDER BY School_Record_Count DESC;


------------------------------------------------------------
-- 11. SCHOOL TYPE MIX
------------------------------------------------------------
SELECT
    s.School_Type,
    COUNT(*) AS Records,
    COUNT(DISTINCT s.School_Name) AS Distinct_Schools
FROM Fact_Table_Advance f
JOIN Dim_School_Data s
    ON f.Dim_School_Data_Key = s.Dim_School_Data_Key
GROUP BY s.School_Type
ORDER BY Records DESC;


------------------------------------------------------------
-- 12. TRANSPORT MODE MIX BY STATE
------------------------------------------------------------
SELECT
    g.State,
    t.Mode,
    COUNT(*) AS Records,
    COUNT(DISTINCT t.Stop_Name) AS Distinct_Stops
FROM Fact_Table_Advance f
JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
JOIN Dim_Transport_Data t
    ON f.Dim_Transport_Data_Key = t.Dim_Transport_Data_Key
GROUP BY g.State, t.Mode
ORDER BY g.State, Records DESC;


------------------------------------------------------------
-- 13. CRIME CATEGORY MIX
------------------------------------------------------------
SELECT
    c.Offense_Category,
    COUNT(*) AS Records,
    SUM(COALESCE(f.Recorded_Incidents, 0)) AS Recorded_Incidents
FROM Fact_Table_Advance f
JOIN Dim_Crime c
    ON f.Dim_Crime_Data_Key = c.Dim_Crime_Key
GROUP BY c.Offense_Category
ORDER BY Recorded_Incidents DESC;


------------------------------------------------------------
-- 14. CRIME HOTSPOTS BY SUBURB
------------------------------------------------------------
SELECT TOP (20)
    g.State,
    g.City,
    g.Suburb,
    SUM(COALESCE(f.Recorded_Incidents, 0)) AS Recorded_Incidents,
    AVG(f.House_Value) AS Avg_House_Value
FROM Fact_Table_Advance f
JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
GROUP BY g.State, g.City, g.Suburb
ORDER BY Recorded_Incidents DESC, Avg_House_Value DESC;


------------------------------------------------------------
-- 15. CROSS-DOMAIN SUBURB PROFILE
------------------------------------------------------------
SELECT
    g.State,
    g.City,
    g.Suburb,
    AVG(f.House_Value) AS Avg_House_Value,
    AVG(f.Rental_Amount) AS Avg_Rental_Amount,
    SUM(COALESCE(f.Recorded_Incidents, 0)) AS Recorded_Incidents,
    COUNT(DISTINCT s.School_Name) AS Distinct_Schools,
    COUNT(DISTINCT t.Stop_Name) AS Distinct_Transport_Stops
FROM Fact_Table_Advance f
JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
LEFT JOIN Dim_School_Data s
    ON f.Dim_School_Data_Key = s.Dim_School_Data_Key
LEFT JOIN Dim_Transport_Data t
    ON f.Dim_Transport_Data_Key = t.Dim_Transport_Data_Key
GROUP BY g.State, g.City, g.Suburb
ORDER BY Avg_House_Value DESC;





------------------------------------------------------------
-- 16. HOUSE-VALUE TO RENTAL RATIO
------------------------------------------------------------
SELECT
    g.State,
    g.City,
    g.Suburb,
    AVG(f.House_Value) AS Avg_House_Value,
    AVG(f.Rental_Amount) AS Avg_Rental_Amount,
    AVG(f.House_Value) / NULLIF(AVG(f.Rental_Amount), 0) AS Avg_Value_To_Rental_Ratio
FROM Fact_Table_Advance f
JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
WHERE f.House_Value IS NOT NULL
  AND f.Rental_Amount IS NOT NULL
GROUP BY g.State, g.City, g.Suburb
ORDER BY Avg_Value_To_Rental_Ratio;


------------------------------------------------------------
-- 17. PROPERTY + CRIME CONTEXT
------------------------------------------------------------
SELECT
    g.State,
    g.City,
    g.Suburb,
    AVG(f.House_Value) AS Avg_House_Value,
    SUM(COALESCE(f.Recorded_Incidents, 0)) AS Recorded_Incidents,
    AVG(CAST(f.Recorded_Incidents AS decimal(18,2))) AS Avg_Incidents_Per_Record
FROM Fact_Table_Advance f
JOIN Dim_Geography_Data g
    ON f.Dim_Geography_Data_Key = g.Dim_Geography_Data_Key
GROUP BY g.State, g.City, g.Suburb
HAVING COUNT(*) >= 1
ORDER BY Recorded_Incidents DESC, Avg_House_Value DESC;




