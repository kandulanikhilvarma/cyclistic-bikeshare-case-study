-- =====================================================
-- CYCLISTIC BIKE-SHARE — DATA CLEANING
-- =====================================================
-- Project : Google Data Analytics Capstone
-- Author  : Nikhilvarma Kandula
-- Date    : May 2026
-- Tool    : Google BigQuery
-- Dataset : cyclistic-case-study-496709.cyclist_data
-- =====================================================

-- OBJECTIVE:
-- Clean 12 months of raw Divvy bike-share data (May 2025 – April 2026).
-- Remove invalid trips, create calculated columns, prepare for analysis.

-- =====================================================
-- CLEANING RULES APPLIED (same for every month):
-- =====================================================
-- 1. Remove rows with missing GPS coords  → end_lat / end_lng IS NULL
-- 2. Remove rides < 1 minute             → false starts / test rides
-- 3. Remove rides > 24 hours (1440 min)  → unreturned / stolen bikes
-- 4. Remove negative durations           → timestamp data error
-- 5. Add ride_length_minutes             → TIMESTAMP_DIFF in minutes
-- 6. Add day_of_week                     → EXTRACT(DAYOFWEEK): 1=Sun, 7=Sat
--
-- NOTE on blank station names:
-- start_station_name / end_station_name may be blank for app-unlocked rides.
-- These are VALID rides and are intentionally kept.
-- Station-level analyses filter with: WHERE start_station_name IS NOT NULL
-- =====================================================


-- ── 2026-04 (trips_202604) ────────────────────────────────────
-- Raw: 448,254 | GPS removed: 364 | <1 min: 12,420 | >24h: 12
-- Clean: ~435,458

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202604_clean` AS
SELECT
  ride_id, rideable_type, started_at, ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM started_at)            AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202604`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;


-- ── 2026-03 (trips_202603) ────────────────────────────────────
-- Raw: 317,037 | GPS removed: 285 | <1 min: 8,286 | >24h: 266

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202603_clean` AS
SELECT
  ride_id, rideable_type, started_at, ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM started_at)            AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202603`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;


-- ── 2026-02 (trips_202602) — STRING timestamp variant ─────────
-- Raw: 197,296 | GPS removed: 0 | <1 min: 4,022 | >24h: 117
-- NOTE: This month's timestamps were stored as STRING, not TIMESTAMP.
--       Root cause: file was opened and re-saved in Excel, which
--       reformatted the datetime columns. PARSE_TIMESTAMP is required.

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202602_clean` AS
SELECT
  ride_id,
  rideable_type,
  PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', started_at) AS started_at,
  PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', ended_at)   AS ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', ended_at),
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', started_at),
    MINUTE
  ) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', started_at)) AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202602`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(
        PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', ended_at),
        PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', started_at),
        MINUTE
      ) >= 1
  AND TIMESTAMP_DIFF(
        PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', ended_at),
        PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', started_at),
        MINUTE
      ) <= 1440;


-- ── 2025-12 (trips_202512) ────────────────────────────────────
-- Raw: 140,534 | GPS removed: 122 | <1 min: 3,961 | >24h: 125

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202512_clean` AS
SELECT
  ride_id, rideable_type, started_at, ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM started_at)            AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202512`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;


-- ── 2025-11 (trips_202511) ────────────────────────────────────
-- Raw: 356,628 | GPS removed: 357 | <1 min: 9,549 | >24h: 337 | negatives: 29

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202511_clean` AS
SELECT
  ride_id, rideable_type, started_at, ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM started_at)            AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202511`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;
-- NOTE: 29 negative-duration rows also removed by the >= 1 condition above.
-- Only November 2025 was affected. Likely caused by the US daylight saving
-- clock-back in early November.


-- ── 2025-10 (trips_202510) ────────────────────────────────────
-- Raw: 646,039 | GPS removed: 586 | <1 min: 17,016 | >24h: 599

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202510_clean` AS
SELECT
  ride_id, rideable_type, started_at, ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM started_at)            AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202510`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;


-- ── 2025-09 (trips_202509) ────────────────────────────────────
-- Raw: 714,759 | GPS removed: 619 | <1 min: 18,293 | >24h: 618

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202509_clean` AS
SELECT
  ride_id, rideable_type, started_at, ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM started_at)            AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202509`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;


-- ── 2025-08 (trips_202508) ────────────────────────────────────
-- Raw: 790,177 | GPS removed: 693 | <1 min: 22,938 | >24h: 702

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202508_clean` AS
SELECT
  ride_id, rideable_type, started_at, ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM started_at)            AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202508`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;


-- ── 2025-07 (trips_202507) ────────────────────────────────────
-- Raw: 763,432 | GPS removed: 971 | <1 min: 23,630 | >24h: 978

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202507_clean` AS
SELECT
  ride_id, rideable_type, started_at, ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM started_at)            AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202507`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;


-- ── 2025-06 (trips_202506) ────────────────────────────────────
-- Raw: 678,904 | GPS removed: 988 | <1 min: 19,622 | >24h: 983

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202506_clean` AS
SELECT
  ride_id, rideable_type, started_at, ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM started_at)            AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202506`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;


-- ── 2025-05 (trips_202505) ────────────────────────────────────
-- Raw: 502,456 | GPS removed: 551 | <1 min: 12,362 | >24h: 563

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202505_clean` AS
SELECT
  ride_id, rideable_type, started_at, ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM started_at)            AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202505`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;


-- ── 2025-01 (trips_202501) ────────────────────────────────────
-- Raw: 137,787 | GPS removed: 196 | <1 min: 3,846 | >24h: 191

CREATE OR REPLACE TABLE `cyclistic-case-study-496709.cyclist_data.trips_202501_clean` AS
SELECT
  ride_id, rideable_type, started_at, ended_at,
  start_station_name, start_station_id,
  end_station_name,   end_station_id,
  start_lat, start_lng, end_lat, end_lng, member_casual,
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
  EXTRACT(DAYOFWEEK FROM started_at)            AS day_of_week
FROM `cyclistic-case-study-496709.cyclist_data.trips_202501`
WHERE end_lat IS NOT NULL
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440;


-- =====================================================
-- VERIFICATION QUERIES (run after cleaning each month)
-- =====================================================

-- 1. Row count before vs after
SELECT 'Original' AS dataset, COUNT(*) AS total_rows
FROM `cyclistic-case-study-496709.cyclist_data.trips_202604`
UNION ALL
SELECT 'Cleaned', COUNT(*)
FROM `cyclistic-case-study-496709.cyclist_data.trips_202604_clean`;

-- 2. Confirm no rides outside 1–1440 min remain
SELECT
  MIN(ride_length_minutes) AS shortest_ride,
  MAX(ride_length_minutes) AS longest_ride,
  ROUND(AVG(ride_length_minutes), 2) AS avg_ride,
  COUNT(*)                 AS total_rides
FROM `cyclistic-case-study-496709.cyclist_data.trips_202604_clean`;

-- 3. Confirm member_casual has exactly 2 values
SELECT member_casual, COUNT(*) AS count
FROM `cyclistic-case-study-496709.cyclist_data.trips_202604_clean`
GROUP BY member_casual;

-- 4. Confirm day_of_week is 1–7
SELECT day_of_week, COUNT(*) AS rides
FROM `cyclistic-case-study-496709.cyclist_data.trips_202604_clean`
GROUP BY day_of_week
ORDER BY day_of_week;
