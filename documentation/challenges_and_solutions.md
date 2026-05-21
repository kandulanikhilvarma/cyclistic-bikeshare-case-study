# Challenges & Solutions

**Project:** Cyclistic Bike-Share Case Study  
**Author:** Nikhilvarma Kandula  
**Context:** Real challenges encountered during the analysis

This document records every significant technical challenge and how it was resolved — demonstrating problem-solving skills, adaptability, and professional judgement.

---

## Challenge 1: Tool Selection — Sheets vs SQL for Large Data

### The Problem
Started cleaning the data in Google Sheets (online spreadsheet).

What went wrong:
- Summer month files had 600,000–800,000 rows each
- Google Sheets crashed when deleting 88,000 rows at once
- "Page unresponsive" errors became frequent
- Each file was taking 30+ minutes to clean manually
- Extrapolated: all 12 files would take 20+ hours this way

### Why It Happened
Browser-based tools have memory constraints — JavaScript engines running in a tab cannot efficiently handle mass operations on hundreds of thousands of rows.

### The Solution
Switched to **Google BigQuery** (cloud-based SQL database).

Why this worked:
- Server-side processing — not limited by browser memory
- One SQL query cleans an entire month in ~2 seconds
- `CREATE OR REPLACE TABLE` makes every step reproducible
- Industry-standard tool for data analysis at scale

### Lesson Learned
Excel and Sheets are not designed for big data. Recognising when to escalate to the right tool — rather than forcing a familiar tool to do a job it was not built for — is a core analyst skill.

---

## Challenge 2: BigQuery File Upload Limits

### The Problem
BigQuery's web interface has a 100 MB direct upload limit. Summer files (June–August) exceeded this unzipped.

Error received:
```
Local uploads are limited to 100 MB.
Please use Google Cloud Storage for larger files.
```

### The Solution
Two-step upload process:

1. Upload all 12 CSVs to Google Cloud Storage (no size limit)
2. In BigQuery: Create Table → Source: Google Cloud Storage → point to bucket

```
GCS bucket: gs://kandula-casestudys/cyclistic-raw-data/
Total uploaded: ~245 MB across 12 files
```

### Why This Matters
Demonstrates understanding of cloud architecture layers — GCS for storage, BigQuery for compute. This is exactly how production data pipelines work in industry.

### Lesson Learned
Read error messages carefully — they often contain the solution. The BigQuery error message literally said "use Google Cloud Storage."

---

## Challenge 3: Data Type Corruption from Excel

### The Problem
The February 2026 cleaning query failed with:
```
Error: TIMESTAMP function expects TIMESTAMP, got STRING
```

Root cause investigation:
- Opened the file in a text editor
- Timestamps read: `08:34.4` instead of `2026-02-15 08:34:24`
- Traced back: this file had been opened and re-saved in Excel earlier
- Excel had reformatted the datetime columns, stripping the date and keeping only the time component

### Why It Happened
Excel "helpfully" reformats data when opening CSVs. It converts timestamps to its internal date serial format and, depending on the cell display format, may export only the visible portion when saved back as CSV.

### The Solution
For February 2026 only, used `PARSE_TIMESTAMP` in the cleaning query:

```sql
-- Normal months (timestamp type):
started_at,

-- February 2026 (string type — Excel corruption):
PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', started_at) AS started_at
```

Full modified query is in `sql/01_data_cleaning.sql`.

### Prevention
**Never open raw data CSVs in Excel.** This is a well-known data quality risk — Excel corrupts datetime values, leading zeros in ZIP codes, scientific gene names (e.g., SEPT2 → September 2), and more. Raw data should only be viewed in a text editor and transformed in SQL or Python.

---

## Challenge 4: Visualizing Both User Groups on a Map

### The Problem
The Tableau station map showed only casual rider stations (orange circles). Member stations (blue circles) were absent.

Diagnosis:
- Query used `ORDER BY total_rides DESC LIMIT 40`
- Top 40 overall = all casual stations (Navy Pier, Millennium Park, lakefront)
- Member stations had lower individual counts and did not make the global top 40

### The Solution
Split the query: top 20 per group, then `UNION ALL`:

```sql
(SELECT ... WHERE member_casual = 'casual' ORDER BY total_rides DESC LIMIT 20)
UNION ALL
(SELECT ... WHERE member_casual = 'member' ORDER BY total_rides DESC LIMIT 20)
```

Result: map shows equal representation of both groups, making the contrast between tourist clustering (casual) and city-wide distribution (member) clearly visible.

### Lesson Learned
A "top N overall" query hides minority groups. When comparing two segments, use stratified or group-specific limits to ensure balanced representation. This applies equally in SQL, Python, and visualisation tools.

---

## Challenge 5: Understanding Blank Station Names — Missing Data vs Valid Pattern

### The Problem
Approximately 20% of rides had blank `start_station_name` and `end_station_name` values. Initial instinct: delete these as incomplete data.

### Research Revealed
Cyclistic's mobile app allows riders to unlock bikes anywhere in the service area — not only at physical docking stations. Blank station names are the expected output when a ride is app-initiated.

Deleting 20% of rides would:
- Eliminate a major and growing usage pattern
- Bias all analysis toward traditional dock-based behaviour
- Distort the casual vs member comparison (app unlocking is proportionally higher for certain ride types)

### The Decision
**KEEP blank station names** in the main analysis table.  
**Filter them out** only in station-level analyses with `WHERE start_station_name IS NOT NULL`.

### Lesson Learned
Context matters. "Missing" data is not always bad data — it can represent a legitimate behaviour that the data model does not capture with a visible value. Always research *why* data is missing before deciding to delete it.

---

## Challenge 6: Negative Ride Durations in November 2025

### The Problem
29 rows in November 2025 had `ended_at` timestamps earlier than `started_at`, producing negative ride lengths. No other month was affected.

### Root Cause
The US daylight saving time transition occurs in early November (clocks move back 1 hour). Rides that spanned the clock-back moment may have had their timestamps recorded inconsistently — the start recorded in summer time, the end in winter time — creating an apparent negative duration.

### The Solution
These 29 rows are removed by the `>= 1` cleaning condition. They were identified explicitly through a dedicated check (`WHERE TIMESTAMP_DIFF(...) < 0`) and documented here for transparency.

### Lesson Learned
Temporal data carries real-world complexity: timezones, daylight saving transitions, and leap seconds can all produce unexpected values. Always run explicit checks for negative durations, not just checks for values above/below business thresholds.

---

## Challenge 7: Choosing Between Python and SQL

### The Internal Debate

| Factor | Python (pandas) | SQL (BigQuery) |
|--------|----------------|---------------|
| Familiarity | Higher | Lower at start |
| Setup | Local install, 2 GB download | Cloud, no local storage |
| Scale | Memory-limited | Handles billions of rows |
| Reproducibility | Script file | SQL file (equally reproducible) |
| Industry relevance | High | High (especially for data analyst roles) |

### The Decision
**BigQuery + SQL** — because it handles cloud-scale data natively, produces clean and auditable queries, and is explicitly listed in data analyst job descriptions. Choosing an unfamiliar but more appropriate tool over a comfortable one was a deliberate professional development choice.

---

## Challenge 8: Tableau Public Limitation — No Direct BigQuery Connection

### The Problem
Tableau Public cannot connect directly to BigQuery (that feature requires paid Tableau Desktop). The entire analysis existed in BigQuery with no way to pull it into Tableau automatically.

### The Solution
Export → import workflow:
1. Run each analysis query in BigQuery
2. Export results as CSV (query results → Save Results → CSV)
3. Import CSVs into Tableau Public as flat files
4. Build all visualisations from the CSVs

Trade-offs:
- No live data connection (acceptable — this is a historical snapshot)
- Manual re-export if data changes (acceptable — project is complete)
- Still produces professional, portfolio-quality interactive dashboards

### Lesson Learned
Free tools have limitations; creative workarounds demonstrate resourcefulness. In a professional environment, access to paid tools would eliminate this step entirely.

---

## Challenge 9: Deciding What NOT to Visualise

### The Problem
After 5 analyses, there were 20+ possible charts. The temptation was to show everything.

### The Solution
Limit: **5 charts maximum**, each answering exactly one key question and directly supporting one marketing recommendation:

| Chart | Question | Recommendation supported |
|-------|----------|--------------------------|
| Bar: avg duration | Do they ride differently? | Rec 3 (leisure messaging) |
| Clustered bar: day of week | When do they ride? | Rec 1 (weekend campaign) |
| Line: monthly trends | Are they seasonal? | Rec 1 (summer timing) |
| Map: top stations | Where do they ride? | Rec 2 (station ad placement) |
| Stacked bar: bike type | What do they ride? | Rec 3 (leisure messaging) |

### Lesson Learned
In professional analysis, every visualisation needs a "so what?" — a clear connection to a decision or recommendation. Clarity beats comprehensiveness.

---

## Technical Stack — Before and After

| Layer | Initial (Failed) | Final (Used) |
|-------|-----------------|--------------|
| Data cleaning | Google Sheets | Google BigQuery (SQL) |
| Data storage | Local CSV files | Google Cloud Storage |
| Analysis | Excel formulas | SQL queries |
| Visualisation | Excel charts | Tableau Public |
| Version control | None | GitHub repository |

---

## What I Would Do Differently Next Time

1. **Start with BigQuery immediately** — do not attempt spreadsheets for datasets > 100K rows
2. **Never open CSVs in Excel** — use a text editor for spot-checking only
3. **Read tool documentation before starting** — would have saved hours of trial and error
4. **Set up folder structure before downloading data** — cleaner organisation from day one
5. **Document decisions in real time** — retroactive documentation is more effort and less accurate

---

## Conclusion

Each challenge in this project forced a deliberate decision: which tool, which approach, which data to keep or remove, and how to present findings clearly. Encountering and resolving these problems built more practical competence than a smooth run would have.

**The measure of a good analyst is not avoiding problems — it is solving them systematically and documenting why.**

---

*Last updated: May 2026*
