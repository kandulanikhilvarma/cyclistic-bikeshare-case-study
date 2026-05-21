-- =====================================================
-- CYCLISTIC BIKE-SHARE — ANALYSIS QUERIES
-- =====================================================
-- Project : Google Data Analytics Capstone
-- Author  : Nikhilvarma Kandula
-- Date    : May 2026
-- Tool    : Google BigQuery
-- Table   : cyclistic-case-study-496709.cyclist_data.all_trips_clean
--           (5,535,455 rows)
-- =====================================================

-- BUSINESS QUESTION:
-- How do annual members and casual riders use Cyclistic bikes differently?

-- ANALYSES IN THIS FILE:
-- 1. Ride Duration Comparison
-- 2. Weekly Usage Patterns (day of week)
-- 3. Seasonal Trends (monthly)
-- 4. Top Station Locations (balanced per group)
-- 5. Bike Type Preferences (with window function %)
-- 6. Peak Hour Analysis (bonus — useful for ad timing)
-- 7. Overall Dataset Summary (for report header stats)
-- =====================================================


-- =====================================================
-- ANALYSIS 1: RIDE DURATION
-- =====================================================
-- Do casual riders take longer trips than members?

SELECT
  member_casual,
  COUNT(*)                            AS total_rides,
  ROUND(AVG(ride_length_minutes), 2)  AS avg_ride_length_minutes,
  ROUND(MIN(ride_length_minutes), 2)  AS min_ride_length,
  ROUND(MAX(ride_length_minutes), 2)  AS max_ride_length
FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`
GROUP BY member_casual;

-- RESULTS:
-- casual  | 1,952,907 | 19.18 min avg
-- member  | 3,582,548 | 11.76 min avg
-- INSIGHT: Casuals ride 63% longer — leisure vs commute behaviour


-- =====================================================
-- ANALYSIS 2: WEEKLY USAGE PATTERNS
-- =====================================================
-- Which days do each group ride most?

SELECT
  member_casual,
  day_of_week,
  CASE day_of_week
    WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    WHEN 7 THEN 'Saturday'
  END AS day_name,
  COUNT(*)                            AS total_rides,
  ROUND(AVG(ride_length_minutes), 2)  AS avg_ride_length
FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`
GROUP BY member_casual, day_of_week
ORDER BY member_casual, day_of_week;

-- RESULTS:
-- Casual peak → Saturday  398,006 rides
-- Member peak → Thursday  589,185 rides
-- Casuals: 37% of rides on Sat+Sun  |  Members: 77% Mon-Fri
-- INSIGHT: Casuals = weekend leisure, members = weekday commuters


-- =====================================================
-- ANALYSIS 3: SEASONAL TRENDS (MONTHLY)
-- =====================================================
-- Are casual riders more seasonal than members?

SELECT
  member_casual,
  EXTRACT(MONTH FROM started_at) AS month,
  CASE EXTRACT(MONTH FROM started_at)
    WHEN 1  THEN 'January'
    WHEN 2  THEN 'February'
    WHEN 3  THEN 'March'
    WHEN 4  THEN 'April'
    WHEN 5  THEN 'May'
    WHEN 6  THEN 'June'
    WHEN 7  THEN 'July'
    WHEN 8  THEN 'August'
    WHEN 9  THEN 'September'
    WHEN 10 THEN 'October'
    WHEN 11 THEN 'November'
    WHEN 12 THEN 'December'
  END AS month_name,
  COUNT(*)                            AS total_rides,
  ROUND(AVG(ride_length_minutes), 2)  AS avg_ride_length
FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`
GROUP BY member_casual, month
ORDER BY member_casual, month;

-- RESULTS:
-- Casual: Aug peak 323,523 → Jan low 23,876  = 93% seasonal drop
-- Member: Aug peak 443,125 → Jan low 109,855 = 75% seasonal drop
-- INSIGHT: Casuals are 4.5× more seasonal — weather-dependent tourists


-- =====================================================
-- ANALYSIS 4: TOP STATION LOCATIONS
-- =====================================================
-- Where do each group start their rides?
-- Version A: simple top-20 overall
-- Version B: top-20 PER GROUP (balanced — better for Tableau maps)

-- ── Version A: Top 20 overall ────────────────────────────────
SELECT
  member_casual,
  start_station_name,
  COUNT(*) AS total_rides
FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`
WHERE start_station_name IS NOT NULL
  AND start_station_name != ''
GROUP BY member_casual, start_station_name
ORDER BY member_casual, total_rides DESC
LIMIT 20;


-- ── Version B: Top 20 per group (USE THIS FOR MAPS) ──────────
(
  SELECT
    member_casual,
    start_station_name,
    AVG(start_lat) AS latitude,
    AVG(start_lng) AS longitude,
    COUNT(*)        AS total_rides
  FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`
  WHERE start_station_name IS NOT NULL
    AND start_station_name != ''
    AND start_lat IS NOT NULL
    AND start_lng IS NOT NULL
    AND member_casual = 'casual'
  GROUP BY member_casual, start_station_name
  ORDER BY total_rides DESC
  LIMIT 20
)
UNION ALL
(
  SELECT
    member_casual,
    start_station_name,
    AVG(start_lat) AS latitude,
    AVG(start_lng) AS longitude,
    COUNT(*)        AS total_rides
  FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`
  WHERE start_station_name IS NOT NULL
    AND start_station_name != ''
    AND start_lat IS NOT NULL
    AND start_lng IS NOT NULL
    AND member_casual = 'member'
  GROUP BY member_casual, start_station_name
  ORDER BY total_rides DESC
  LIMIT 20
)
ORDER BY member_casual, total_rides DESC;

-- RESULTS — Top 3 Casual Stations (all tourist / lakefront):
-- 1. Navy Pier                           32,173 rides
-- 2. DuSable Lake Shore Dr & Monroe St   31,083 rides
-- 3. Michigan Ave & Oak St               22,257 rides
-- INSIGHT: Casuals cluster at tourist/leisure destinations


-- =====================================================
-- ANALYSIS 5: BIKE TYPE PREFERENCES
-- =====================================================
-- Do the groups choose different bike types?
-- How does bike type affect ride duration?

SELECT
  member_casual,
  rideable_type,
  COUNT(*)                            AS total_rides,
  ROUND(AVG(ride_length_minutes), 2)  AS avg_ride_length,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY member_casual),
    2
  )                                   AS pct_of_group
FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`
GROUP BY member_casual, rideable_type
ORDER BY member_casual, total_rides DESC;

-- RESULTS:
-- casual  | electric_bike | 1,294,903 | 14.33 min | 66%
-- casual  | classic_bike  |   658,004 | 28.72 min | 34%  ← leisure indicator
-- member  | electric_bike | 2,310,294 | 10.87 min | 65%
-- member  | classic_bike  | 1,272,254 | 13.38 min | 35%
-- INSIGHT: Casual classic-bike rides are 2× longer than member equivalent


-- =====================================================
-- ANALYSIS 6: PEAK HOUR (BONUS)
-- =====================================================
-- When during the day do each group ride?
-- Useful for targeting in-app and outdoor ad timing.

SELECT
  member_casual,
  EXTRACT(HOUR FROM started_at) AS hour_of_day,
  COUNT(*)                       AS total_rides
FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`
GROUP BY member_casual, hour_of_day
ORDER BY member_casual, hour_of_day;

-- Expected pattern:
-- Members → twin peaks at ~8 AM and ~5-6 PM (commute hours)
-- Casuals → single broad peak 11 AM – 6 PM (leisure hours)


-- =====================================================
-- ANALYSIS 7: OVERALL DATASET SUMMARY
-- =====================================================
-- One-query header stats for the final report / README

SELECT
  COUNT(*)                                            AS total_rides,
  COUNT(DISTINCT ride_id)                             AS unique_ride_ids,
  MIN(started_at)                                     AS earliest_ride,
  MAX(ended_at)                                       AS latest_ride,
  COUNT(DISTINCT start_station_name)                  AS unique_stations,
  ROUND(AVG(ride_length_minutes), 2)                  AS overall_avg_ride_min,
  COUNTIF(member_casual = 'casual')                   AS casual_total,
  COUNTIF(member_casual = 'member')                   AS member_total,
  ROUND(COUNTIF(member_casual = 'casual') * 100.0
        / COUNT(*), 1)                                AS casual_pct,
  ROUND(COUNTIF(member_casual = 'member') * 100.0
        / COUNT(*), 1)                                AS member_pct
FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`;
