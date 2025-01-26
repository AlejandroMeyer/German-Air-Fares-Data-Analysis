-----------------------------------------------------------
------------------- DROP TEMPORAL TABLE -------------------
-----------------------------------------------------------

DROP TABLE IF EXISTS #temp1_german_air
DROP TABLE IF EXISTS #temp2_german_air
DROP TABLE IF EXISTS #temp3_german_air
DROP TABLE IF EXISTS #temp4_german_air
DROP TABLE IF EXISTS [DWH].[dbo].[temp_2_german_air_fares] 


-----------------------------------------------------------
-----------------------------------------------------------



SELECT [departure_city]
      ,[arrival_city]
	  ,CONVERT(date, scrape_date, 104) AS [scrape_date]
	  ,CONVERT(date, [departure_date], 104) AS [departure_date]
	  ,LEFT([departure_date_distance], PATINDEX('%[^0-9]%', [departure_date_distance]) - 1) AS [day]
      ,LTRIM(RTRIM(SUBSTRING([departure_date_distance], PATINDEX('%[^0-9]%', [departure_date_distance]), LEN([departure_date_distance])))) AS [date_type]
      ,[departure_time]
      ,[arrival_time]
      ,[airline]
	  ,CASE
        WHEN PATINDEX('%[0-9]%', [stops]) > 0 THEN CAST(SUBSTRING([stops], PATINDEX('%[0-9]%', [stops]), 1) AS INT)
        ELSE 0
       END AS [stops]
      ,TRY_CONVERT(FLOAT,[price]) AS [price]
  INTO #temp1_german_air
  FROM [DWH].[dbo].[temp_german_air_fares] WITH(NOLOCK)
  WHERE [departure_date_distance] IS NOT NULL
  AND PATINDEX('%[^0-9]%', [departure_date_distance]) > 0
  AND [stops] IS NOT NULL


-- The calculation of days in reserve, transformation of weeks and months to days is made.

SELECT [departure_city]
      ,[arrival_city]
	  ,[scrape_date]
	  ,[departure_date]
	  --,[day]
      --,[date_type]
	  ,CASE
		WHEN [date_type] IN ('week','weeks') THEN [day] * 7 
		WHEN [date_type] IN ('months','month')	THEN [day] * 30
		ELSE 0
	   END AS [departure_date_distance]
      ,[departure_time]
      ,[arrival_time]
      ,[airline]
	  ,[stops]
      ,[price]
INTO #temp2_german_air
FROM #temp1_german_air WITH(NOLOCK)
-- SELECT * FROM #temp1_german_air WITH(NOLOCK)


-- The [departure_time] and [arrival_time] fields are cleaned, the text pm, am and uhr are removed, and the [pm_index] column is added to identify if the field should be added 12 hours for being pm.

SELECT
	 [departure_city]
    ,[arrival_city]
	,[scrape_date]
	,[departure_date]
	,[departure_date_distance]
    ,[departure_time]
    ,LTRIM(RTRIM(
        CASE 
            WHEN PATINDEX('%[0-9]%', REVERSE([departure_time])) > 0 THEN REVERSE(SUBSTRING(REVERSE([departure_time]), PATINDEX('%[0-9]%', REVERSE([departure_time])), LEN([departure_time])))
            ELSE [departure_time]
        END
    )) AS [cleaned_departure_time]
	,CASE 
        WHEN LOWER(RIGHT([departure_time], 2)) = 'pm' THEN 1
        ELSE 0
    END AS [pm_index_departure]
	,[arrival_time]
	,LTRIM(RTRIM(
        CASE 
            WHEN PATINDEX('%[0-9]%', REVERSE([arrival_time])) > 0 THEN REVERSE(SUBSTRING(REVERSE([arrival_time]), PATINDEX('%[0-9]%', REVERSE([arrival_time])), LEN([arrival_time])))
            ELSE [arrival_time]
        END
    )) AS [cleaned_arrival_time]
	,CASE 
        WHEN LOWER(RIGHT([arrival_time], 2)) = 'pm' THEN 1
        ELSE 0
    END AS [pm_index_arrival]
	,[airline]
	,[stops]
    ,[price]
INTO #temp3_german_air
FROM #temp2_german_air

-- SELECT * FROM #temp3_german_air WITH(NOLOCK)



-- I add the 12 hours, validation if it is 12 pm, am or uhr does not add up, everything else adds up to 12 hours. 

SELECT 
	 [departure_city]
    ,[arrival_city]
	,[scrape_date]
	,[departure_date]
	,[departure_date_distance]
	--,[departure_time]
    ,CASE 
        WHEN PATINDEX('%[0-9]%', REVERSE([departure_time])) > 0 THEN
            CONVERT(VARCHAR(5), 
                DATEADD(HOUR, 
                    CASE 
                        WHEN [pm_index_departure] = 1 AND LEFT(LTRIM(RTRIM(REVERSE(SUBSTRING(REVERSE([departure_time]), PATINDEX('%[0-9]%', REVERSE([departure_time])), LEN([departure_time]))))), 2) <> '12' 
                        THEN 12 
                        ELSE 0 
                    END, 
                    CONVERT(TIME, 
                        LTRIM(RTRIM(REVERSE(SUBSTRING(REVERSE([departure_time]), PATINDEX('%[0-9]%', REVERSE([departure_time])), LEN([departure_time]))))))))
        ELSE [departure_time]
    END AS [cleaned_departure_time]
    --,[pm_index_departure]
	--,[arrival_time]
	,CASE 
        WHEN PATINDEX('%[0-9]%', REVERSE([arrival_time])) > 0 THEN
            CONVERT(VARCHAR(5), 
                DATEADD(HOUR, 
                    CASE 
                        WHEN [pm_index_arrival] = 1 AND LEFT(LTRIM(RTRIM(REVERSE(SUBSTRING(REVERSE([arrival_time]), PATINDEX('%[0-9]%', REVERSE([arrival_time])), LEN([arrival_time]))))), 2) <> '12' 
                        THEN 12 
                        ELSE 0 
                    END, 
                    CONVERT(TIME, 
                        LTRIM(RTRIM(REVERSE(SUBSTRING(REVERSE([arrival_time]), PATINDEX('%[0-9]%', REVERSE([arrival_time])), LEN([arrival_time]))))))))
        ELSE [departure_time]
    END AS [cleaned_arrival_time]
	--,[pm_index_arrival]
	,[airline]
	,[stops]
    ,[price]
INTO #temp4_german_air
FROM #temp3_german_air



-- Temp table 2

CREATE TABLE [DWH].[dbo].[temp_2_german_air_fares](
	[departure_city]			VARCHAR(30) NULL,
	[arrival_city]				VARCHAR(30) NULL,
	[scrape_date]				DATE		NULL,
	[departure_date]			DATE		NULL,
	[departure_date_distance]	INT			NULL,
	[cleaned_departure_time]	TIME		NULL,
	[cleaned_arrival_time]		TIME		NULL,
	[airline]					VARCHAR(30) NULL,
	[stops]						VARCHAR(2)	NULL,
	[price]						INT			NULL,
)


INSERT INTO [DWH].[dbo].[temp_2_german_air_fares]
SELECT 
	 [departure_city]
    ,[arrival_city]
	,[scrape_date]
	,[departure_date]
	,[departure_date_distance]
	,[cleaned_departure_time]
	,[cleaned_arrival_time]
	,[airline]
	,[stops]
    ,[price]
FROM #temp4_german_air WITH(NOLOCK)

-- SELECT * FROM [DWH].[dbo].[temp_2_german_air_fares] WITH(NOLOCK)

-----------------------------------------------------------
------------------- DROP TEMPORAL TABLE -------------------
-----------------------------------------------------------

DROP TABLE IF EXISTS #temp1_german_air
DROP TABLE IF EXISTS #temp2_german_air
DROP TABLE IF EXISTS #temp3_german_air
DROP TABLE IF EXISTS #temp4_german_air
DROP TABLE IF EXISTS [DWH].[dbo].[temp_2_german_air_fares] 

-----------------------------------------------------------
-----------------------------------------------------------

