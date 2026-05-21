# Data Cleaning Log

**Project:** Cyclistic Bike-Share Case Study  
**Author:** Nikhilvarma Kandula  
**Date Range:** May 2025 – April 2026 (12 months)  
**Tool:** Google BigQuery (SQL) + Google Sheets (spot-checks on smaller months)

---

## Overview

12 monthly CSV files were sourced from the Divvy public dataset (Motivate International Inc.). Each file was cleaned individually using identical logic before being merged into a single analysis table (`all_trips_clean`). All cleaning is reproducible via the SQL in `sql/01_data_cleaning.sql`.

---

## Raw Data Summary

| Month | File | Raw Rows | Approx. Size |
|-------|------|----------|--------------|
| May 2025 | 202505-divvy-tripdata.csv | 502,456 | ~20 MB |
| June 2025 | 202506-divvy-tripdata.csv | 678,904 | ~28 MB |
| July 2025 | 202507-divvy-tripdata.csv | 763,432 | ~30 MB |
| August 2025 | 202508-divvy-tripdata.csv | 790,177 | ~30 MB |
| September 2025 | 202509-divvy-tripdata.csv | 714,759 | ~28 MB |
| October 2025 | 202510-divvy-tripdata.csv | 646,039 | ~25 MB |
| November 2025 | 202511-divvy-tripdata.csv | 356,628 | ~14 MB |
| December 2025 | 202512-divvy-tripdata.csv | 140,534 | ~6 MB |
| January 2026 | 202501-divvy-tripdata.csv | 137,787 | ~6 MB |
| February 2026 | 202602-divvy-tripdata.csv | 197,296 | ~8 MB |
| March 2026 | 202603-divvy-tripdata.csv | 317,037 | ~13 MB |
| April 2026 | 202604-divvy-tripdata.csv | 448,254 | ~17 MB |
| **TOTAL** | **12 files** | **~5,693,303** | **~245 MB** |

---

## Data Quality Issues & Decisions

### Issue 1: Missing GPS Coordinates (end_lat / end_lng)

**Check:** `WHERE end_lat IS NULL OR end_lng IS NULL`  
**Decision: DELETE.**

Rows with missing GPS end coordinates cannot be mapped or used for spatial analysis. They represent GPS failure or trips that were never properly ended — not legitimate rides.

| Month | GPS rows removed |
|-------|-----------------|
| 2026-04 | 364 |
| 2026-03 | 285 |
| 2026-02 | 0 |
| 2025-12 | 122 |
| 2025-11 | 357 |
| 2025-10 | 586 |
| 2025-09 | 619 |
| 2025-08 | 693 |
| 2025-07 | 971 |
| 2025-06 | 988 |
| 2025-05 | 551 |
| 2025-01 | 196 |

---

### Issue 2: Rides Under 1 Minute

**Check:** `TIMESTAMP_DIFF(ended_at, started_at, MINUTE) < 1`  
**Decision: DELETE.**

Sub-minute rides are false starts, accidental unlocks, or immediate re-docks. They cannot represent real trips and would skew average duration downward. The Divvy system itself does not charge for rides under 60 seconds on some plan types.

| Month | Rows removed |
|-------|-------------|
| 2026-04 | 12,420 |
| 2026-03 | 8,286 |
| 2026-02 | 4,022 |
| 2025-12 | 3,961 |
| 2025-11 | 9,549 |
| 2025-10 | 17,016 |
| 2025-09 | 18,293 |
| 2025-08 | 22,938 |
| 2025-07 | 23,630 |
| 2025-06 | 19,622 |
| 2025-05 | 12,362 |
| 2025-01 | 3,846 |

---

### Issue 3: Rides Over 24 Hours (1,440 Minutes)

**Check:** `TIMESTAMP_DIFF(ended_at, started_at, MINUTE) > 1440`  
**Decision: DELETE.**

Rides exceeding 24 hours represent bikes that were not returned — stolen, lost, or system errors. They are extreme outliers that would heavily distort average duration, especially for casual riders.

| Month | Rows removed |
|-------|-------------|
| 2026-04 | 12 |
| 2026-03 | 266 |
| 2026-02 | 117 |
| 2025-12 | 125 |
| 2025-11 | 337 |
| 2025-10 | 599 |
| 2025-09 | 618 |
| 2025-08 | 702 |
| 2025-07 | 978 |
| 2025-06 | 983 |
| 2025-05 | 563 |
| 2025-01 | 191 |

---

### Issue 4: Negative Ride Durations

**Check:** `TIMESTAMP_DIFF(ended_at, started_at, MINUTE) < 0`  
**Decision: DELETE.**

Negative durations mean `ended_at` is before `started_at` — a physical impossibility caused by timestamp errors. The `>= 1` cleaning condition removes these implicitly, but they were checked explicitly.

| Month | Negatives found |
|-------|----------------|
| 2025-11 November | **29** |
| All other months | 0 |

The November 2025 negatives are likely caused by the US daylight saving clock-back (clocks move back 1 hour in early November), creating apparent overlap in timestamps.

---

### Issue 5: Blank Station Names — KEPT INTENTIONALLY

**Check:** `start_station_name IS NULL OR start_station_name = ''`  
**Decision: KEEP.**

Large numbers of rows have blank station names — approximately 20% of all trips in some months. These are **valid app-unlocked rides**: Cyclistic allows users to unlock bikes via the mobile app anywhere in the city, not just at physical docking stations. Deleting these would remove a major usage pattern and bias the analysis toward traditional station-based behaviour.

For station-specific analyses (Analysis 4), these are filtered out with `WHERE start_station_name IS NOT NULL`.

| Month | Start station blanks (kept) | End station blanks (kept) |
|-------|---------------------------|--------------------------|
| 2026-04 | 91,991 | 94,286 |
| 2026-03 | 57,776 | 62,761 |
| 2026-02 | 32,069 | 34,861 |

---

### Issue 6: Data Type Corruption — February 2026

**Problem:** `started_at` and `ended_at` columns were stored as STRING instead of TIMESTAMP in the February 2026 file.  
**Root cause:** The CSV was opened and re-saved in Excel, which reformatted the timestamps and corrupted the data type. Excel strips the date portion when cell formatting is set to show only time.  
**Decision:** Use `PARSE_TIMESTAMP` to convert strings back to proper timestamps during cleaning.

```sql
PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', started_at) AS started_at
```

See `sql/01_data_cleaning.sql` for the full modified query for this month.

**Prevention:** Never open raw data CSVs in Excel. Use a text editor (VS Code, Notepad++) for quick viewing only.

---

### Issue 7: Duplicate ride_id Values

**Check:** `GROUP BY ride_id HAVING COUNT(*) > 1`  
**Result:** Zero duplicates found across all 12 months.  
**Decision:** No action required.

---

## Engineered Columns Added

### `ride_length_minutes`
```sql
TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes
```
- Unit: minutes (more interpretable than seconds or hours)
- Validated range after cleaning: 1–1,440
- Casual average: 19.18 min | Member average: 11.76 min

### `day_of_week`
```sql
EXTRACT(DAYOFWEEK FROM started_at) AS day_of_week
```
- 1 = Sunday, 2 = Monday, … 7 = Saturday (matches Google Sheets WEEKDAY formula with type 1)
- Cross-checked: 2026-04-06 (a confirmed Sunday) returns 1 in both BigQuery and Sheets ✅

---

## Final Cleaned Data Summary

| Metric | Value |
|--------|-------|
| **Total rows after cleaning** | 5,535,455 |
| **Rows removed** | ~157,848 (~2.8% of original) |
| **Date range** | 2025-05-01 to 2026-04-30 |
| **Columns** | 15 (13 original + 2 calculated) |
| **Member rides** | 3,582,548 (64.7%) |
| **Casual rides** | 1,952,907 (35.3%) |
| **Unique ride_ids** | 5,535,455 (zero cross-month duplicates) |

### April 2026 — Detailed Example

| Check | Before | After | Removed | % Removed |
|-------|--------|-------|---------|-----------|
| Total rows | 448,254 | ~435,458 | ~12,796 | 2.9% |
| Missing GPS | 364 | 0 | 364 | 0.08% |
| Rides < 1 min | 12,420 | 0 | 12,420 | 2.77% |
| Rides > 24 hrs | 12 | 0 | 12 | 0.003% |
| Duplicates | 0 | 0 | 0 | 0% |

---

## Assumptions & Limitations

**Assumptions made:**
1. Rides under 1 minute are not legitimate customer trips
2. Rides over 24 hours represent system errors or unreturned bikes, not intentional usage
3. Blank station names represent valid app-based unlocking, not missing data
4. All timestamps are in local Chicago time (Central Time)

**Limitations:**
1. No user-level data: cannot track individual behaviour over time (privacy protection — no PII in dataset)
2. No pricing data: cannot calculate revenue per trip or customer lifetime value
3. No demographic data: cannot segment by age, gender, or home neighbourhood
4. One-year snapshot: seasonal patterns assumed to repeat; longer-term trends unknown

---

## Reproducibility

All cleaning queries are in `sql/01_data_cleaning.sql` and `sql/02_data_merging.sql`.

To reproduce:
1. Download raw CSVs from [Divvy data source](https://divvy-tripdata.s3.amazonaws.com/index.html)
2. Upload to Google Cloud Storage (files > 100 MB require GCS; direct BigQuery upload limit is 100 MB)
3. Load from GCS into BigQuery as 12 raw tables
4. Run `01_data_cleaning.sql` (one block per month)
5. Run `02_data_merging.sql` to create `all_trips_clean`
6. Run `03_analysis_queries.sql` for all analysis results

---

*Last updated: May 2026*
