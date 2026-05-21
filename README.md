# 🚴 Cyclistic Bike-Share Case Study

[![View Tableau Dashboard](https://img.shields.io/badge/Tableau-Dashboard-blue?style=for-the-badge&logo=tableau)](YOUR_TABLEAU_PUBLIC_LINK_HERE)
[![View SQL Code](https://img.shields.io/badge/SQL-BigQuery-orange?style=for-the-badge&logo=google-cloud)](./sql/)
[![Read Full Report](https://img.shields.io/badge/Report-PDF-red?style=for-the-badge&logo=adobe)](./reports/cyclistic_report.pdf)

---

## 📊 Project Overview

**Business Question:** How do annual members and casual riders use Cyclistic bikes differently?

**Goal:** Design marketing strategies to convert casual riders into annual members based on data-driven insights.

**Tools Used:**
- **Google BigQuery** — SQL data cleaning and analysis (5.5M rows)
- **Google Cloud Storage** — Large file uploads
- **Tableau Public** — Interactive visualizations
- **Microsoft PowerPoint & Word** — Executive presentations and reports

---

## 🎯 Key Findings

| Finding | Casual Riders | Annual Members | Insight |
|---------|---------------|----------------|---------|
| **Average Ride Duration** | 19.18 minutes | 11.76 minutes | Casuals take **63% longer rides** — leisure vs. commute behavior |
| **Peak Usage Day** | Saturday (398K rides) | Thursday (589K rides) | Casuals = weekends, Members = weekday commuters |
| **Seasonal Pattern** | 93% drop in winter | 75% drop in winter | Casuals are highly weather-dependent tourists |
| **Top Stations** | Navy Pier, Millennium Park | Distributed across city | Casuals cluster at tourist attractions |
| **Bike Preference** | 66% electric (but 28.7 min on classic bikes) | 65% electric (13.4 min average) | Casuals use classic bikes for long leisure rides |

---

## 📈 Visualizations

### Tableau Dashboard
![Cyclistic Dashboard](./visualizations/tableau_dashboard.png)

**[→ View Interactive Dashboard on Tableau Public](YOUR_TABLEAU_PUBLIC_LINK_HERE)**

<details>
<summary><b>Click to see individual charts</b></summary>

### 1. Weekly Usage Patterns
![Rides by Day](./visualizations/rides_by_day.png)

### 2. Seasonal Trends (May 2025 - April 2026)
![Monthly Trends](./visualizations/monthly_trends.png)

### 3. Average Ride Duration Comparison
![Avg Ride Length](./visualizations/avg_ride_length.png)

### 4. Bike Type Preferences
![Bike Type Usage](./visualizations/bike_type_usage.png)

### 5. Top Station Locations
![Station Map](./visualizations/station_map.png)

</details>

---

## 💡 Marketing Recommendations

Based on the data analysis, I recommend three targeted strategies:

### 1️⃣ Weekend & Summer Membership Campaign
**Data Support:** 72% of casual rides occur May-August; Saturday peak = 398K rides  
**Strategy:** Launch "Weekend Rider → Annual Member" upgrade offer targeting users with 3+ rides/month via in-app notifications during peak season (May-August).

### 2️⃣ Digital Ads at Casual Hotspot Stations
**Data Support:** Top 3 casual stations (Navy Pier, DuSable Lake Shore Dr, Michigan Ave) = 85K rides  
**Strategy:** Install QR-code displays at tourist-heavy stations showing live cost savings comparison: "5 rides this month? You'd save $12 with membership."

### 3️⃣ Reframe Membership as Leisure Lifestyle
**Data Support:** Casual riders average 19 min per ride; classic bike rides average 28.7 min (pure leisure)  
**Strategy:** Shift marketing from "commute convenience" to "explore more, pay less" — use lakefront and weekend imagery, not rush-hour messaging.

---

## 🗂️ Data & Methodology

### Data Source
- **Dataset:** Divvy Bikes public trip data (Motivate International Inc.)
- **Period:** May 2025 - April 2026 (12 months)
- **Total Rows:** 5,535,455 trips (after cleaning)
- **License:** Public use with privacy protection (no PII)

### Data Cleaning Process

**Initial Data Quality Issues:**
- 362 rows with missing GPS coordinates (end_lat/end_lng)
- 12,420 rides under 1 minute (test rides/false starts)
- 354 rides over 24 hours (unreturned bikes)
- 0 duplicate ride_ids ✅

**Cleaning Rules Applied (SQL in BigQuery):**
```sql
WHERE 
  end_lat IS NOT NULL 
  AND end_lng IS NOT NULL
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1
  AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440
```

**New Columns Created:**
- `ride_length_minutes` = `TIMESTAMP_DIFF(ended_at, started_at, MINUTE)`
- `day_of_week` = `EXTRACT(DAYOFWEEK FROM started_at)` (1=Sunday, 7=Saturday)

**[→ View Complete SQL Code](./sql/)**

---

## 📁 Repository Structure

```
cyclistic-bikeshare-case-study/
├── README.md                          ← You are here
├── data/
│   ├── raw                           ← Unprocessed data(5.5M rows)
|   ├── processed                     ← Cleaned data
│   └── analyzed                      ← Analyzed data
├── sql/
│   ├── 01_data_cleaning.sql           ← Cleaning queries for all 12 months
│   ├── 02_data_merging.sql            ← UNION ALL query (12 months → 1 table)
│   └── 03_analysis_queries.sql        ← All 5 analysis queries
├── visualizations/
│   └── *.png                          ← Tableau dashboard + individual charts
├── reports/
│   ├── cyclistic_presentation.pdf     ← Executive slide deck (9 slides)
│   └── cyclistic_report.pdf           ← Full analysis report (5 sections)
└── documentation/
    ├── data_cleaning_log.md           ← Cleaning decisions documented
    ├── challenges_and_solutions.md    ← Problems solved during analysis
    └── key_findings.md                ← Summary of insights
```

---

## 🛠️ Technical Skills Demonstrated

- **SQL (BigQuery):** Complex queries, CTEs, date functions, aggregations, UNION ALL
- **Data Cleaning:** Handling missing values, outlier removal, data type conversions
- **Cloud Infrastructure:** Google Cloud Storage, BigQuery dataset management
- **Data Visualization:** Tableau Public (maps, dual-axis charts, dashboards)
- **Statistical Analysis:** Descriptive statistics, trend analysis, segmentation
- **Business Communication:** Translating technical findings into actionable recommendations

---

## 🚀 How to Reproduce This Analysis

### Prerequisites
- Google Cloud Platform account (free tier)
- Tableau Public (free)
- Access to Divvy trip data: https://divvy-tripdata.s3.amazonaws.com/index.html

### Steps
1. **Download 12 months of data** (most recent)
2. **Upload to Google Cloud Storage** (files > 100MB)
3. **Load into BigQuery** tables (12 raw tables)
4. **Run cleaning SQL** from [`sql/01_data_cleaning.sql`](./sql/01_data_cleaning.sql)
5. **Merge tables** using [`sql/02_data_merging.sql`](./sql/02_data_merging.sql)
6. **Run analysis queries** from [`sql/03_analysis_queries.sql`](./sql/03_analysis_queries.sql)
7. **Export results as CSV** and load into Tableau
8. **Build visualizations** following dashboard design

**[→ Detailed Step-by-Step Guide](./documentation/reproduction_guide.md)**

---

## 📚 Additional Resources

- **[Full Analysis Report](./reports/cyclistic_report.pdf)** — Detailed findings and methodology
- **[Executive Presentation](./reports/cyclistic_presentation.pdf)** — 9-slide deck for stakeholders
- **[Data Cleaning Log](./documentation/data_cleaning_log.md)** — All cleaning decisions documented
- **[Challenges & Solutions](./documentation/challenges_and_solutions.md)** — Problems I solved during the project

---

## 👤 About Me

I completed this project as part of the **Google Data Analytics Professional Certificate**. This case study demonstrates my ability to:
- Clean and analyze large datasets (5M+ rows)
- Use industry-standard tools (SQL, BigQuery, Tableau)
- Derive actionable business insights from data
- Communicate findings to non-technical stakeholders

**Connect with me:**
- 💼 [LinkedIn](YOUR_LINKEDIN_URL)
- 📧 [Email](mailto:your.email@example.com)
- 🌐 [Portfolio](YOUR_PORTFOLIO_WEBSITE)

---

## 📄 License

This project uses public data from Motivate International Inc. under their data license agreement. The code and documentation in this repository are available under the MIT License.

---

**⭐ If you found this project helpful, please star this repository!**

*Last Updated: May 2026*
