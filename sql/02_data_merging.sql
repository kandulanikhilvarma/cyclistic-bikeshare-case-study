-- =====================================================
-- CYCLISTIC BIKE-SHARE — DATA MERGING
-- =====================================================
-- Project : Google Data Analytics Capstone
-- Author  : Nikhilvarma Kandula
-- Date    : May 2026
-- Tool    : Google BigQuery
-- Dataset : cyclistic-case-study-496709.cyclist_data
-- =====================================================

-- OBJECTIVE:
-- Merge 12 cleaned monthly tables into one master table for analysis.
-- INPUT  : 12 _clean tables (trips_202501_clean … trips_202604_clean)
-- OUTPUT : all_trips_clean — 5,535,455 rows
-- =====================================================


CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.all_trips_clean` AS

-- April 2026
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202604_clean`
UNION ALL
-- March 2026
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202603_clean`
UNION ALL
-- February 2026
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202602_clean`
UNION ALL
-- December 2025
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202512_clean`
UNION ALL
-- November 2025
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202511_clean`
UNION ALL
-- October 2025
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202510_clean`
UNION ALL
-- September 2025
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202509_clean`
UNION ALL
-- August 2025
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202508_clean`
UNION ALL
-- July 2025
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202507_clean`
UNION ALL
-- June 2025
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202506_clean`
UNION ALL
-- May 2025
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202505_clean`
UNION ALL
-- January 2025
SELECT * FROM `cyclistic-case-study-496709.cyclist_data.trips_202501_clean`;


-- =====================================================
-- VERIFICATION (run immediately after CREATE)
-- =====================================================

-- 1. Total rows + unique ride_ids (both should be 5,535,455)
SELECT
  COUNT(*)                AS total_rows,
  COUNT(DISTINCT ride_id) AS unique_rides
FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`;

-- 2. All 12 months present, in order
SELECT
  EXTRACT(YEAR  FROM started_at) AS year,
  EXTRACT(MONTH FROM started_at) AS month,
  COUNT(*)                        AS rides
FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`
GROUP BY year, month
ORDER BY year, month;

-- 3. Member / casual split
SELECT
  member_casual,
  COUNT(*) AS total_rides,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
    2
  ) AS pct_of_all_rides
FROM `cyclistic-case-study-496709.cyclist_data.all_trips_clean`
GROUP BY member_casual;

-- Expected results:
-- total_rows    → 5,535,455
-- unique_rides  → 5,535,455  (no cross-month duplicates)
-- months        → 12 distinct year-month combinations
-- member        → 3,582,548  (64.7%)
-- casual        → 1,952,907  (35.3%)
