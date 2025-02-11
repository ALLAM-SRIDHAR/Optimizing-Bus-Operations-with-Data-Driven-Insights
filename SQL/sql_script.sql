show databases;
create database project_team_238;
use project_team_238;
show tables;

select * from bus_data;

DESCRIBE bus_data;
----------------------------------------------------------------
-- Total rows in the table
select count(*) from bus_data;

-- List all column names and data types
select column_name, data_type from information_schema.columns where table_name='bus_data';

--------------------------------------------------------------
-- Backup the data

create table bus_data_backup as select * from bus_data;
------------------------------------------------------------------
#Changing data-types of columns (to change datatypes temporrily we can use cast() and asign an alias name for them, but if you want to change datatype peremanently on table we use alter table command.

-- Change 'Date' to DATE type
# please note that we cannot convert text to date directly with alter command, unless it is already in yyyy-mm-dd format, so first we need to fix that then we need to use alter command
SET sql_safe_updates = 0;  -- Disable safe updates
UPDATE bus_data
SET `Date` = STR_TO_DATE(`Date`, '%d-%m-%Y');
SET sql_safe_updates = 1;  -- Re-enable safe updates after the update
ALTER TABLE bus_data MODIFY COLUMN `Date` DATE;

-- Change 'Trips per Day' to INTEGER

ALTER TABLE bus_data
MODIFY COLUMN `Trips per Day` INT;

-- Change `Bus Stops Covered` to INTEGER  (note: if column names contains spaces then we have to enclose column name in back-ticks( ` ))  
alter table bus_data
modify column `Bus Stops Covered` INT;	

-- Change 'Tickets Sold' to INTEGER
alter table bus_data
modify column `Tickets Sold` INT;

-- Change 'Frequency (mins)' to INTEGER
alter table bus_data
modify column `Frequency (mins)` INT;

-- Change 'Time (mins)' to INTEGER
alter table bus_data
modify column `Time (mins)` INT;

-- Change `Revenue Generated (INR)` to Decimal(10,2)
alter table bus_data
modify column `Revenue Generated (INR)` Decimal(10,2);

-- change `Distance Travelled (km)` to Decimal(10,2)
alter table bus_data 
modify column `Distance Travelled (km)` Decimal(10,2);

-- to verify changes
describe bus_data;

-- if you want to see top 5 rows of data of one column at a time
SELECT `Revenue Generated (INR)`
FROM bus_data -- order by `Revenue Generated (INR)` desc
LIMIT 5;

------------------------------------------------------------
-- Count missing values (NULLs) per column
# syntax for finding in each column
# select column_name, count(*) - count(column_name) as missing_values from bus_data group by column_name;
#select `Bus Route No.`, count(*) - count(`Bus Route No.`) as missing_values_bus_route_no from bus_data group by `Bus Route No.` order by missing_values_bus_route_no desc;


SELECT
    SUM(CASE WHEN `Date` IS NULL THEN 1 ELSE 0 END) AS `Date_missing`,
    SUM(CASE WHEN `Bus Route No.` IS NULL THEN 1 ELSE 0 END) AS `Bus Route No._missing`,
    SUM(CASE WHEN `From` IS NULL THEN 1 ELSE 0 END) AS `From_missing`,
    SUM(CASE WHEN `To` IS NULL THEN 1 ELSE 0 END) AS `To_missing`,
    SUM(CASE WHEN `Trips per Day` IS NULL THEN 1 ELSE 0 END) AS `Trips per Day_missing`,
    SUM(CASE WHEN `Way` IS NULL THEN 1 ELSE 0 END) AS `Way_missing`,
    SUM(CASE WHEN `Bus Stops Covered` IS NULL THEN 1 ELSE 0 END) AS `Bus Stops Covered_missing`,
    SUM(CASE WHEN `Frequency (mins)` IS NULL THEN 1 ELSE 0 END) AS `Frequency (mins)_missing`,
    SUM(CASE WHEN `Distance Travelled (km)` IS NULL THEN 1 ELSE 0 END) AS `Distance Travelled (km)_missing`,
    SUM(CASE WHEN `Time (mins)` IS NULL THEN 1 ELSE 0 END) AS `Time (mins)_missing`,
    SUM(CASE WHEN `Main Station` IS NULL THEN 1 ELSE 0 END) AS `Main Station_missing`,
    SUM(CASE WHEN `Tickets Sold` IS NULL THEN 1 ELSE 0 END) AS `Tickets Sold_missing`,
    SUM(CASE WHEN `Revenue Generated (INR)` IS NULL THEN 1 ELSE 0 END) AS `Revenue Generated (INR)_missing`
FROM bus_data;


-------------------------------------------------------------------------------------
-- to check for duplicates
SELECT * FROM bus_data
GROUP BY `Bus Route No.`, `Date`, `From`, `To`, `Trips per Day`, `Way`, 
         `Bus Stops Covered`, `Frequency (mins)`, `Distance Travelled (km)`,
         `Time (mins)`, `Main Station`, `Tickets Sold`, `Revenue Generated (INR)`
HAVING COUNT(*) > 1;
----------------------------------------------------------------------------------------
-- First moment business decision
#mean
select avg(`Trips per Day`) as mean_trips_per_day from bus_data;
select avg(`Bus Stops Covered`) as mean_bus_stops_covered from bus_data;
select avg(`Frequency (mins)`) as mean_frequency_min from bus_data;
select avg(`Distance Travelled (km)`) as mean_distance_travelled from bus_data;
select avg(`Time (mins)`) as mean_time_min from bus_data;
select avg(`Tickets Sold`) as mean_tickets_sold from bus_data;
select avg(`Revenue Generated (INR)`) as mean_revenue_generated from bus_data;

#median

-- for Trips per Day
SELECT `column` AS median_trips_per_day
FROM (
    SELECT `Trips per Day` AS `column`,
           ROW_NUMBER() OVER (ORDER BY `Trips per Day`) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM bus_data
) AS subquery
WHERE row_num = (total_count + 1) / 2 OR row_num = (total_count + 2) / 2;

-- For 'Distance Travelled (km)'
SELECT `column` AS median_Distance_Travelled
FROM (
    SELECT `Distance Travelled (km)` AS `column`,
           ROW_NUMBER() OVER (ORDER BY `Distance Travelled (km)`) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM bus_data
) AS subquery
WHERE row_num = (total_count + 1) / 2 OR row_num = (total_count + 2) / 2;

-- For 'Revenue Generated (INR)'
SELECT `column` AS median_Revenue_Generated
FROM (
    SELECT `Revenue Generated (INR)` AS `column`,
           ROW_NUMBER() OVER (ORDER BY `Revenue Generated (INR)`) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM bus_data
) AS subquery
WHERE row_num = (total_count + 1) / 2 OR row_num = (total_count + 2) / 2;

-- For 'Frequency (mins)'
SELECT `column` AS median_frequency_min
FROM (
    SELECT `Frequency (mins)` AS `column`,
           ROW_NUMBER() OVER (ORDER BY `Frequency (mins)`) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM bus_data
) AS subquery
WHERE row_num = (total_count + 1) / 2 OR row_num = (total_count + 2) / 2;

-- For `Time (mins)`
SELECT `column` AS median_time_min
FROM (
    SELECT `Time (mins)` AS `column`,
           ROW_NUMBER() OVER (ORDER BY `Time (mins)`) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM bus_data
) AS subquery
WHERE row_num = (total_count + 1) / 2 OR row_num = (total_count + 2) / 2;

-- for `Bus Stops Covered`
SELECT `column` AS median_bus_stops_covered
FROM (
    SELECT `Bus Stops Covered` AS `column`,
           ROW_NUMBER() OVER (ORDER BY `Bus Stops Covered`) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM bus_data
) AS subquery
WHERE row_num = (total_count + 1) / 2 OR row_num = (total_count + 2) / 2;

-- for `Tickets Sold`
SELECT `column` AS median_bus_stops_covered
FROM (
    SELECT `Tickets Sold` AS `column`,
           ROW_NUMBER() OVER (ORDER BY `Tickets Sold`) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM bus_data
) AS subquery
WHERE row_num = (total_count + 1) / 2 OR row_num = (total_count + 2) / 2;

#mode
-- for Trips per Day
SELECT `Trips per Day`, COUNT(`Trips per Day`) AS frequency
FROM bus_data
GROUP BY `Trips per Day`
ORDER BY frequency DESC
LIMIT 1;

-- for `Bus Stops Covered`
SELECT `Bus Stops Covered`, COUNT(`Bus Stops Covered`) AS frequency
FROM bus_data
GROUP BY `Bus Stops Covered`
ORDER BY frequency DESC
LIMIT 1;

-- for `Frequency (mins)`
SELECT `Frequency (mins)`, COUNT(`Frequency (mins)`) AS frequency
FROM bus_data
GROUP BY `Frequency (mins)`
ORDER BY frequency DESC
LIMIT 1;

-- for `Distance Travelled (km)`
SELECT `Distance Travelled (km)`, COUNT(`Distance Travelled (km)`) AS frequency
FROM bus_data
GROUP BY `Distance Travelled (km)`
ORDER BY frequency DESC
LIMIT 1;

-- for `Time (mins)`
SELECT `Time (mins)`, COUNT(`Time (mins)`) AS frequency
FROM bus_data
GROUP BY `Time (mins)`
ORDER BY frequency DESC
LIMIT 1;

-- for `Tickets Sold`
SELECT `Tickets Sold`, COUNT(`Tickets Sold`) AS frequency
FROM bus_data
GROUP BY `Tickets Sold`
ORDER BY frequency DESC
LIMIT 1;

-- for `Revenue Generated (INR)`
SELECT `Revenue Generated (INR)`, COUNT(`Revenue Generated (INR)`) AS frequency
FROM bus_data
GROUP BY `Revenue Generated (INR)`
ORDER BY frequency DESC
LIMIT 1;

--------------------------------------------------------------
#Second moment business decisions
#variance
-- Variance for 'Trips per Day'
SELECT VAR_POP(`Trips per Day`) AS variance_Trips_per_Day
FROM bus_data;

-- Variance for 'Bus Stops Covered'
SELECT VAR_POP(`Bus Stops Covered`) AS variance_Bus_Stops_Covered
FROM bus_data;

-- Variance for 'Frequency (mins)'
SELECT VAR_POP(`Frequency (mins)`) AS variance_Frequency
FROM bus_data;

-- Variance for 'Distance Travelled (km)'
SELECT VAR_POP(`Distance Travelled (km)`) AS variance_Distance_Travelled
FROM bus_data;

-- Variance for 'Time (mins)'
SELECT VAR_POP(`Time (mins)`) AS variance_Time
FROM bus_data;

-- Variance for 'Tickets Sold'
SELECT VAR_POP(`Tickets Sold`) AS variance_Tickets_Sold
FROM bus_data;

-- Variance for 'Revenue Generated (INR)'
SELECT VAR_POP(`Revenue Generated (INR)`) AS variance_Revenue_Generated
FROM bus_data;

#Standard Deviation
-- Standard Deviation for 'Trips per Day'
SELECT STDDEV_POP(`Trips per Day`) AS stddev_Trips_per_Day
FROM bus_data;

-- Standard Deviation for 'Bus Stops Covered'
SELECT STDDEV_POP(`Bus Stops Covered`) AS stddev_Bus_Stops_Covered
FROM bus_data;

-- Standard Deviation for 'Frequency (mins)'
SELECT STDDEV_POP(`Frequency (mins)`) AS stddev_Frequency
FROM bus_data;

-- Standard Deviation for 'Distance Travelled (km)'
SELECT STDDEV_POP(`Distance Travelled (km)`) AS stddev_Distance_Travelled
FROM bus_data;

-- Standard Deviation for 'Time (mins)'
SELECT STDDEV_POP(`Time (mins)`) AS stddev_Time
FROM bus_data;

-- Standard Deviation for 'Tickets Sold'
SELECT STDDEV_POP(`Tickets Sold`) AS stddev_Tickets_Sold
FROM bus_data;

-- Standard Deviation for 'Revenue Generated (INR)'
SELECT STDDEV_POP(`Revenue Generated (INR)`) AS stddev_Revenue_Generated
FROM bus_data;

#range
-- Range for 'Trips per Day'
SELECT MAX(`Trips per Day`) - MIN(`Trips per Day`) AS range_Trips_per_Day
FROM bus_data;

-- Range for 'Bus Stops Covered'
SELECT MAX(`Bus Stops Covered`) - MIN(`Bus Stops Covered`) AS range_Bus_Stops_Covered
FROM bus_data;

-- Range for 'Frequency (mins)'
SELECT MAX(`Frequency (mins)`) - MIN(`Frequency (mins)`) AS range_Frequency
FROM bus_data;

-- Range for 'Distance Travelled (km)'
SELECT MAX(`Distance Travelled (km)`) - MIN(`Distance Travelled (km)`) AS range_Distance_Travelled
FROM bus_data;

-- Range for 'Time (mins)'
SELECT MAX(`Time (mins)`) - MIN(`Time (mins)`) AS range_Time
FROM bus_data;

-- Range for 'Tickets Sold'
SELECT MAX(`Tickets Sold`) - MIN(`Tickets Sold`) AS range_Tickets_Sold
FROM bus_data;

-- Range for 'Revenue Generated (INR)'
SELECT MAX(`Revenue Generated (INR)`) - MIN(`Revenue Generated (INR)`) AS range_Revenue_Generated
FROM bus_data;


#Third moment business Decision
#skewness
-- for Trips per Day
SELECT 
    (SUM(POWER(`Trips per Day` - (SELECT AVG(`Trips per Day`) FROM bus_data), 3)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Trips per Day`) FROM bus_data), 3))) AS skewness_Trips_per_Day
FROM bus_data;

-- for Bus Stops Covered
SELECT 
    (SUM(POWER(`Bus Stops Covered` - (SELECT AVG(`Bus Stops Covered`) FROM bus_data), 3)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Bus Stops Covered`) FROM bus_data), 3))) AS skewness_Bus_Stops_Covered
FROM bus_data;

-- for Frequency (min)
SELECT 
    (SUM(POWER(`Frequency (mins)` - (SELECT AVG(`Frequency (mins)`) FROM bus_data), 3)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Frequency (mins)`) FROM bus_data), 3))) AS skewness_Frequency
FROM bus_data;

-- for Distance Travelled in (Km)
SELECT 
    (SUM(POWER(`Distance Travelled (km)` - (SELECT AVG(`Distance Travelled (km)`) FROM bus_data), 3)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Distance Travelled (km)`) FROM bus_data), 3))) AS skewness_Distance_Travelled
FROM bus_data;

-- for Time (min)
SELECT 
    (SUM(POWER(`Time (mins)` - (SELECT AVG(`Time (mins)`) FROM bus_data), 3)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Time (mins)`) FROM bus_data), 3))) AS skewness_Time
FROM bus_data;

-- for tickets sold
SELECT 
    (SUM(POWER(`Tickets Sold` - (SELECT AVG(`Tickets Sold`) FROM bus_data), 3)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Tickets Sold`) FROM bus_data), 3))) AS skewness_Tickets_Sold
FROM bus_data;


-- for revenue generated
SELECT 
    (SUM(POWER(`Revenue Generated (INR)` - (SELECT AVG(`Revenue Generated (INR)`) FROM bus_data), 3)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Revenue Generated (INR)`) FROM bus_data), 3))) AS skewness_Revenue_Generated
FROM bus_data;


# Fourth Moment Business Decision (kurtosis)
-- for Trips per Day
SELECT 
    (SUM(POWER(`Trips per Day` - (SELECT AVG(`Trips per Day`) FROM bus_data), 4)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Trips per Day`) FROM bus_data), 4))) - 3 AS kurtosis_Trips_per_Day
FROM bus_data;

-- For Bus Stops Covered
SELECT 
    (SUM(POWER(`Bus Stops Covered` - (SELECT AVG(`Bus Stops Covered`) FROM bus_data), 4)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Bus Stops Covered`) FROM bus_data), 4))) - 3 AS kurtosis_Bus_Stops_Covered
FROM bus_data;

 -- for frquency (min)
 SELECT 
    (SUM(POWER(`Frequency (mins)` - (SELECT AVG(`Frequency (mins)`) FROM bus_data), 4)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Frequency (mins)`) FROM bus_data), 4))) - 3 AS kurtosis_Frequency
FROM bus_data;

-- for distance travelled (km)
SELECT 
    (SUM(POWER(`Distance Travelled (km)` - (SELECT AVG(`Distance Travelled (km)`) FROM bus_data), 4)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Distance Travelled (km)`) FROM bus_data), 4))) - 3 AS kurtosis_Distance_Travelled
FROM bus_data;

-- for Time (min)
SELECT 
    (SUM(POWER(`Time (mins)` - (SELECT AVG(`Time (mins)`) FROM bus_data), 4)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Time (mins)`) FROM bus_data), 4))) - 3 AS kurtosis_Time
FROM bus_data;

-- forTickets Sols
SELECT 
    (SUM(POWER(`Tickets Sold` - (SELECT AVG(`Tickets Sold`) FROM bus_data), 4)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Tickets Sold`) FROM bus_data), 4))) - 3 AS kurtosis_Tickets_Sold
FROM bus_data;

-- for Revenuue Generated
SELECT 
    (SUM(POWER(`Revenue Generated (INR)` - (SELECT AVG(`Revenue Generated (INR)`) FROM bus_data), 4)) / 
    (COUNT(*) * POWER((SELECT STDDEV(`Revenue Generated (INR)`) FROM bus_data), 4))) - 3 AS kurtosis_Revenue_Generated
FROM bus_data;

-------------------------------------------------------------------
#Handling missing values
## to see missing values
SELECT
    SUM(CASE WHEN `Date` IS NULL THEN 1 ELSE 0 END) AS `Date_missing`,
    SUM(CASE WHEN `Bus Route No.` IS NULL THEN 1 ELSE 0 END) AS `Bus Route No._missing`,
    SUM(CASE WHEN `From` IS NULL THEN 1 ELSE 0 END) AS `From_missing`,
    SUM(CASE WHEN `To` IS NULL THEN 1 ELSE 0 END) AS `To_missing`,
    SUM(CASE WHEN `Trips per Day` IS NULL THEN 1 ELSE 0 END) AS `Trips per Day_missing`,
    SUM(CASE WHEN `Way` IS NULL THEN 1 ELSE 0 END) AS `Way_missing`,
    SUM(CASE WHEN `Bus Stops Covered` IS NULL THEN 1 ELSE 0 END) AS `Bus Stops Covered_missing`,
    SUM(CASE WHEN `Frequency (mins)` IS NULL THEN 1 ELSE 0 END) AS `Frequency (mins)_missing`,
    SUM(CASE WHEN `Distance Travelled (km)` IS NULL THEN 1 ELSE 0 END) AS `Distance Travelled (km)_missing`,
    SUM(CASE WHEN `Time (mins)` IS NULL THEN 1 ELSE 0 END) AS `Time (mins)_missing`,
    SUM(CASE WHEN `Main Station` IS NULL THEN 1 ELSE 0 END) AS `Main Station_missing`,
    SUM(CASE WHEN `Tickets Sold` IS NULL THEN 1 ELSE 0 END) AS `Tickets Sold_missing`,
    SUM(CASE WHEN `Revenue Generated (INR)` IS NULL THEN 1 ELSE 0 END) AS `Revenue Generated (INR)_missing`
FROM bus_data;

#in Distance Travelled (km) column replace NaN with mean
SET SQL_SAFE_UPDATES = 0;
#SET SQL_SAFE_UPDATES = 1; -- set it on once updations are done
SET @mean_distance_travelled = (SELECT AVG(`Distance Travelled (km)`) FROM bus_data);
update bus_data
set `Distance Travelled (km)` = @mean_distance_travelled
where `Distance Travelled (km)` is null;
-- to verify
select count(*) from bus_data where `Distance Travelled (km)` is null;

SET @mean_frequency_min = (select avg(`Frequency (mins)`) from bus_data);
update bus_data
set `Frequency (mins)` = @mean_frequency_min
where `Frequency (mins)` is null;
-- to verify
select count(*) from bus_data where `Frequency (mins)` is null;

set @mean_time_min = (select avg(`Time (mins)`) from bus_data);
update bus_data
set `Time (mins)` = @mean_time_min
where `Time (mins)` is null;
-- to verify
select count(*) from bus_data where `Time (mins)` is null;

-- for Bus Route No. column:
begin;
WITH missing_values AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY `Bus Route No.`) AS row_index,
        `Bus Route No.`
    FROM bus_data
    WHERE `Bus Route No.` IS NULL
)
UPDATE bus_data
JOIN missing_values
    ON bus_data.`Bus Route No.` IS NULL
    AND missing_values.row_index = (SELECT row_index FROM missing_values WHERE missing_values.row_index = missing_values.row_index LIMIT 1)
SET bus_data.`Bus Route No.` = CASE 
    WHEN missing_values.row_index = 1 THEN '195W'
    WHEN missing_values.row_index = 2 THEN '12'
    WHEN missing_values.row_index = 3 THEN '90L/250'
    WHEN missing_values.row_index = 4 THEN '195'
    WHEN missing_values.row_index = 5 THEN '127K'
    WHEN missing_values.row_index = 6 THEN '127K/V'
    WHEN missing_values.row_index = 7 THEN '231B'
    WHEN missing_values.row_index = 8 THEN '216M'
    WHEN missing_values.row_index = 9 THEN '17H/10W'
    WHEN missing_values.row_index = 10 THEN '127VB'
    WHEN missing_values.row_index = 11 THEN '127K'
    WHEN missing_values.row_index = 12 THEN '127K/V'
    WHEN missing_values.row_index = 13 THEN '118W/218'
    WHEN missing_values.row_index = 14 THEN '113K/Y'
    WHEN missing_values.row_index = 15 THEN '195'
    WHEN missing_values.row_index = 16 THEN '116N'
    WHEN missing_values.row_index = 17 THEN '195E'
    ELSE bus_data.`Bus Route No.`
END;

-- to verify before commit:
SELECT *
FROM bus_data
WHERE `Bus Route No.` IN ('195W', '12', '90L/250', '195', '127K', '127K/V', '231B', '216M', '17H/10W', '127VB', 
                           '127K', '127K/V', '118W/218', '113K/Y', '195', '116N', '195E')
ORDER BY `Bus Route No.`;


commit;

---------------------------------------------------------------------------------------------------------
#-- to check for duplicates and handle duplicates
SELECT * FROM bus_data
GROUP BY `Bus Route No.`, `Date`, `From`, `To`, `Trips per Day`, `Way`, 
         `Bus Stops Covered`, `Frequency (mins)`, `Distance Travelled (km)`,
         `Time (mins)`, `Main Station`, `Tickets Sold`, `Revenue Generated (INR)`
HAVING COUNT(*) > 1;

--------------------------------------------------------------------------------
-- outlier IIdentification and Treatment

SET sql_safe_updates = 0;

begin;
-- Process columns individually
-- Example for 'Trips per Day'
UPDATE bus_data AS e
JOIN (
    SELECT 
        `Trips per Day`,
        NTILE(4) OVER (ORDER BY `Trips per Day`) AS trips_quartile
    FROM bus_data
) AS subquery ON e.`Trips per Day` = subquery.`Trips per Day`
SET e.`Trips per Day` = (
    SELECT AVG(`Trips per Day`)
    FROM (
        SELECT 
            `Trips per Day`,
            NTILE(4) OVER (ORDER BY `Trips per Day`) AS trips_quartile
        FROM bus_data
    ) AS temp
    WHERE trips_quartile = subquery.trips_quartile
)
WHERE subquery.trips_quartile IN (1, 4);
-- to verify:  
select `Trips per Day` from bus_data order by `Trips per Day` DESC limit 5;


-- Bus Stops Covered
UPDATE bus_data AS e
JOIN (
    SELECT 
        `Bus Stops Covered`,
        NTILE(4) OVER (ORDER BY `Bus Stops Covered`) AS stops_quartile
    FROM bus_data
) AS subquery ON e.`Bus Stops Covered` = subquery.`Bus Stops Covered`
SET e.`Bus Stops Covered` = (
    SELECT AVG(`Bus Stops Covered`)
    FROM (
        SELECT 
            `Bus Stops Covered`,
            NTILE(4) OVER (ORDER BY `Bus Stops Covered`) AS stops_quartile
        FROM bus_data
    ) AS temp
    WHERE stops_quartile = subquery.stops_quartile
)
WHERE subquery.stops_quartile IN (1, 4);
-- to verify:  
select `Bus Stops Covered` from bus_data order by `Bus Stops Covered` DESC limit 5;
-------------------------------------------------------------------------------------------------------------------------------
#connection lost to the MySQL server during query
-- Frequency (mins)
UPDATE bus_data AS e
JOIN (
    SELECT 
        `Frequency (mins)`,
        NTILE(4) OVER (ORDER BY `Frequency (mins)`) AS freq_quartile
    FROM bus_data
) AS subquery ON e.`Frequency (mins)` = subquery.`Frequency (mins)`
SET e.`Frequency (mins)` = (
    SELECT AVG(`Frequency (mins)`)
    FROM (
        SELECT 
            `Frequency (mins)`,
            NTILE(4) OVER (ORDER BY `Frequency (mins)`) AS freq_quartile
        FROM bus_data
    ) AS temp
    WHERE freq_quartile = subquery.freq_quartile
)
WHERE subquery.freq_quartile IN (1, 4);
-- to verify:  
select `Frequency (mins)` from bus_data order by `Frequency (mins)` DESC limit 5;

-- Distance Travelled (km)
UPDATE bus_data AS e
JOIN (
    SELECT 
        `Distance Travelled (km)`,
        NTILE(4) OVER (ORDER BY `Distance Travelled (km)`) AS dist_quartile
    FROM bus_data
) AS subquery ON e.`Distance Travelled (km)` = subquery.`Distance Travelled (km)`
SET e.`Distance Travelled (km)` = (
    SELECT AVG(`Distance Travelled (km)`)
    FROM (
        SELECT 
            `Distance Travelled (km)`,
            NTILE(4) OVER (ORDER BY `Distance Travelled (km)`) AS dist_quartile
        FROM bus_data
    ) AS temp
    WHERE dist_quartile = subquery.dist_quartile
)
WHERE subquery.dist_quartile IN (1, 4);
-- to verify:  
select `Distance Travelled (km)` from bus_data order by `Distance Travelled (km)` DESC limit 5;

-- Time (mins)
UPDATE bus_data AS e
JOIN (
    SELECT 
        `Time (mins)`,
        NTILE(4) OVER (ORDER BY `Time (mins)`) AS time_quartile
    FROM bus_data
) AS subquery ON e.`Time (mins)` = subquery.`Time (mins)`
SET e.`Time (mins)` = (
    SELECT AVG(`Time (mins)`)
    FROM (
        SELECT 
            `Time (mins)`,
            NTILE(4) OVER (ORDER BY `Time (mins)`) AS time_quartile
        FROM bus_data
    ) AS temp
    WHERE time_quartile = subquery.time_quartile
)
WHERE subquery.time_quartile IN (1, 4);
-- to verify:  
select `Time (mins)` from bus_data order by `Time (mins)` DESC limit 5;

-- Tickets Sold
UPDATE bus_data AS e
JOIN (
    SELECT 
        `Tickets Sold`,
        NTILE(4) OVER (ORDER BY `Tickets Sold`) AS tickets_quartile
    FROM bus_data
) AS subquery ON e.`Tickets Sold` = subquery.`Tickets Sold`
SET e.`Tickets Sold` = (
    SELECT AVG(`Tickets Sold`)
    FROM (
        SELECT 
            `Tickets Sold`,
            NTILE(4) OVER (ORDER BY `Tickets Sold`) AS tickets_quartile
        FROM bus_data
    ) AS temp
    WHERE tickets_quartile = subquery.tickets_quartile
)
WHERE subquery.tickets_quartile IN (1, 4);
-- to verify:  
select `Tickets Sold` from bus_data order by `Tickets Sold` DESC limit 5;

-- Revenue Generated (INR)
UPDATE bus_data AS e
JOIN (
    SELECT 
        `Revenue Generated (INR)`,
        NTILE(4) OVER (ORDER BY `Revenue Generated (INR)`) AS revenue_quartile
    FROM bus_data
) AS subquery ON e.`Revenue Generated (INR)` = subquery.`Revenue Generated (INR)`
SET e.`Revenue Generated (INR)` = (
    SELECT AVG(`Revenue Generated (INR)`)
    FROM (
        SELECT 
            `Revenue Generated (INR)`,
            NTILE(4) OVER (ORDER BY `Revenue Generated (INR)`) AS revenue_quartile
        FROM bus_data
    ) AS temp
    WHERE revenue_quartile = subquery.revenue_quartile
)
WHERE subquery.revenue_quartile IN (1, 4);
-- to verify:  
select `Revenue Generated (INR)` from bus_data order by `Revenue Generated (INR)` DESC limit 5;

#rollback;
------
-- zero and near-zero variance
SELECT 
    VARIANCE(`Trips per Day`) AS trips_per_day_variance,
    VARIANCE(`Bus Stops Covered`) AS bus_stops_covered_variance,
    VARIANCE(`Frequency (mins)`) AS frequency_variance,
    VARIANCE(`Distance Travelled (km)`) AS distance_travelled_variance,
    VARIANCE(`Time (mins)`) AS time_variance,
    VARIANCE(`Tickets Sold`) AS tickets_sold_variance,
    VARIANCE(`Revenue Generated (INR)`) AS revenue_generated_variance
FROM bus_data;