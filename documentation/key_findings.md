# 🔍 Key Findings — Cyclistic Bike-Share Analysis

**Author:** Nikhilvarma Kandula  
**Data Period:** May 2025 – April 2026 (12 months)  
**Dataset:** 5,535,455 cleaned rides · Divvy Bike-Share · Motivate International Inc.  
**Tools:** Google BigQuery (SQL) · Tableau Public · GitHub  

---

## 📊 Dataset at a Glance

| Metric | Value |
|--------|-------|
| Total rides analyzed | **5,535,455** |
| Data period | May 2025 – April 2026 |
| Annual members | **3,582,548 (64.7%)** |
| Casual riders | **1,952,907 (35.3%)** |
| Months covered | 12 consecutive months |
| Rows removed in cleaning | ~157,848 (~2.8% of raw data) |
| Duplicate ride IDs | 0 (confirmed across all 12 months) |
| Bike types | electric_bike · classic_bike |

---

## 🎯 Finding 1 — Ride Duration: Casuals Ride 63% Longer

**SQL Reference:** `sql/03_analysis_queries.sql` — Analysis 1  
**Visualization:** `visualizations/avg_ride_length.png`  

| Rider Type | Avg Duration | Total Rides | Pattern |
|------------|-------------|-------------|---------|
| **Casual** | **19.2 min** | 1,952,907 | Leisure exploration |
| **Member** | **11.8 min** | 3,582,548 | Efficient commuting |
| **Ratio**  | **1.63×**    | —          | Casuals ride 63% longer |

### By Bike Type

| Bike Type | Casual Avg | Member Avg | Ratio |
|-----------|-----------|-----------|-------|
| Electric Bike | 14.3 min | 10.9 min | 1.31× |
| **Classic Bike** | **28.7 min** | **13.4 min** | **2.14×** ← strongest leisure signal |

### 🔑 Insight
Casual riders on **classic bikes average 28.7 minutes** — nearly 30 minutes per ride. This is not a commute. It is leisurely sightseeing along Chicago's lakefront. The 2.14× classic-bike ratio is the **strongest single leisure indicator** in the entire 5.5M-row dataset.

### ↗ Links to Recommendation 3
> Reframe membership marketing from "commuter efficiency" to "leisure lifestyle." Casuals don't see themselves as commuters — the data proves it.

---

## 🎯 Finding 2 — Weekly Patterns: Casuals Weekend, Members Weekday

**SQL Reference:** `sql/03_analysis_queries.sql` — Analysis 2  
**Visualization:** `visualizations/rides_by_day.png`  

| Day | Casual Rides | Member Rides | Casual % |
|-----|-------------|-------------|---------|
| Sunday | 325,077 | 383,108 | 46% |
| Monday | 223,743 | 503,442 | 31% |
| Tuesday | 220,387 | 569,292 | 28% |
| Wednesday | 220,429 | 567,025 | 28% |
| Thursday | 258,310 | **589,185** ← member peak | 30% |
| Friday | 306,955 | 527,383 | 37% |
| **Saturday** | **398,006** ← casual peak | 443,113 | **47%** |

### Key Statistics
- **37%** of all casual rides occur on Saturday + Sunday
- **77%** of all member rides occur Monday – Friday
- Saturday casual rides (398K) are **78% higher** than the Monday casual low (224K)
- Member Thursday peak (589K) is their most consistent commute day

### 🔑 Insight
The weekly split reveals two fundamentally different user behaviours. Members are **infrastructure users** — bikes are how they get to work. Casual riders are **leisure consumers** — bikes are what they do on weekends.

### ↗ Links to Recommendation 1
> Weekend concentration makes Saturday morning in-app notifications and weekend station promotions the highest-ROI casual touchpoint in the week.

---

## 🎯 Finding 3 — Seasonal Trends: Casuals Are 4.5× More Seasonal

**SQL Reference:** `sql/03_analysis_queries.sql` — Analysis 3  
**Visualization:** `visualizations/monthly_trends.png`  

| Month | Casual Rides | Member Rides | Casual % |
|-------|-------------|-------------|---------|
| January | 23,876 ← winter trough | 109,855 | 18% |
| February | 40,072 | 157,230 | 20% |
| March | 84,796 | 223,643 | 27% |
| April | 127,025 | 308,470 | 29% |
| May | 175,648 | 313,994 | 36% |
| June | 278,675 | 379,517 | 42% |
| July | 308,429 | 430,392 | 42% |
| **August** | **323,523** ← casual peak | **443,125** ← member peak | **42%** |
| September | 254,714 | 440,951 | 37% |
| October | 214,373 | 414,088 | 34% |
| November | 94,689 | 251,912 | 27% |
| December | 27,087 | 109,371 | 20% |

### Seasonal Drop Analysis

| Metric | Casual | Member |
|--------|--------|--------|
| August peak | 323,523 | 443,125 |
| January trough | 23,876 | 109,855 |
| **Seasonal drop** | **93%** | **75%** |
| **Seasonality ratio** | **4.5× more seasonal** | baseline |
| May–Sep share of annual | **72% of all casual rides** | 59% of member |

### 🔑 Insight
Casual ridership nearly **disappears in winter**. Members maintain year-round usage because bikes are their transport infrastructure. The **May–September window is the only realistic time to run conversion campaigns** — 72% of the target audience is only accessible in 5 months.

### ↗ Links to Recommendation 1
> Conversion campaign must launch in May, peak in July–August, and close in September. Running it in winter is wasted budget.

---

## 🎯 Finding 4 — Station Geography: Casuals Cluster at Tourist Hotspots

**SQL Reference:** `sql/03_analysis_queries.sql` — Analysis 4 (Version B — stratified per group)  
**Visualization:** `visualizations/station_map.png`  
**Data:** `data/analyzed/top_stations.csv`  

### Top 10 Casual Start Stations

| Rank | Station | Casual Rides | Location Type |
|------|---------|-------------|---------------|
| 1 | **Navy Pier** | 32,173 | Tourist attraction |
| 2 | **DuSable Lake Shore Dr & Monroe St** | 31,083 | Lakefront park |
| 3 | **Michigan Ave & Oak St** | 22,257 | Shopping / tourism |
| 4 | DuSable Lake Shore Dr & North Blvd | 19,273 | Lakefront park |
| 5 | Streeter Dr & Grand Ave | 18,910 | Lakefront / tourism |
| 6 | Millennium Park | 18,566 | Tourist attraction |
| 7 | Shedd Aquarium | 16,556 | Tourist attraction |
| 8 | Theater on the Lake | 15,635 | Entertainment venue |
| 9 | DuSable Harbor | 15,171 | Lakefront marina |
| 10 | Michigan Ave & 8th St | 10,882 | Tourism corridor |

### Member Station Pattern
Member stations are **distributed across commuter corridors city-wide** — not concentrated at any tourist attraction. They align with transit hubs, office corridors, and residential neighbourhoods.

### Critical Query Design Note
An initial top-40 overall query showed **only casual stations** (their tourist concentrations dominated). The fix: `UNION ALL` of two separate `TOP 20 PER GROUP` queries gives balanced representation on the Tableau map. Full explanation: `documentation/challenges_and_solutions.md` — Challenge 4.

### 🔑 Insight
**Top 3 casual stations alone = 81,313 rides combined.** Every top casual station is a tourist attraction, lakefront park, or leisure destination. These 10 stations are the **highest-ROI locations for physical membership advertising**.

### ↗ Links to Recommendation 2
> QR-code displays and cost-comparison screens at these 10 stations capture riders at the exact moment of maximum purchase intent — when they are physically using the service and have just paid for a casual ride.

---

## 🎯 Finding 5 — Bike Type: Classic Bike Duration Reveals Leisure

**SQL Reference:** `sql/03_analysis_queries.sql` — Analysis 5 (window function for % of group)  
**Visualization:** `visualizations/bike_type_usage.png`  
**Data:** `data/analyzed/bike_type_usage.csv`  

| Group | Bike Type | Rides | % of Group | Avg Duration |
|-------|-----------|-------|-----------|-------------|
| Casual | Electric Bike | 1,294,903 | **66%** | 14.3 min |
| Casual | Classic Bike | 658,004 | **34%** | **28.7 min** |
| Member | Electric Bike | 2,310,294 | **65%** | 10.9 min |
| Member | Classic Bike | 1,272,254 | **35%** | **13.4 min** |

### The Critical Comparison

| Metric | Classic Bike — Casual | Classic Bike — Member | Ratio |
|--------|-----------------------|-----------------------|-------|
| Avg ride duration | **28.7 min** | **13.4 min** | **2.14×** |
| What it signals | Leisure sightseeing | Functional commute | — |

### 🔑 Insight
The **electric vs classic split is nearly identical** between groups (66% vs 65%), so bike type *preference* alone does not distinguish casual from member. The signal is the **duration difference on classic bikes**: casual classic riders take 2.14× longer trips. A 30-minute casual classic bike ride is a lakefront exploration, not a commute.

**SQL technique used:** Window function `SUM(COUNT(*)) OVER (PARTITION BY member_casual)` to calculate percentage-of-group without a subquery.

---

## 🎁 Bonus Finding — Peak Hour Analysis (Ad Timing Intelligence)

**SQL Reference:** `sql/03_analysis_queries.sql` — Analysis 6  

| Rider Type | Morning | Midday–Afternoon | Evening | Pattern |
|------------|---------|-----------------|---------|---------|
| **Member** | Peak 8–9 AM | Moderate | Peak 5–7 PM | Twin commute peaks |
| **Casual** | Flat / no peak | **Peak 11 AM–6 PM** | Tapering | Single leisure arc |

### 🔑 Insight
Members show a classic **commuter twin-peak** pattern (in + out). Casuals show a **single broad leisure block** centred on midday and afternoon. For in-app ads targeting casuals: **Friday 4–8 PM and Saturday 10 AM–2 PM** are the optimal delivery windows.

---

## 📌 3 Data-Backed Recommendations (Act Phase)

### Recommendation 1 — Weekend & Summer Conversion Campaign `HIGH PRIORITY`
**Evidence:** Casual Saturday peak 398K · May–Sep = 72% of casual rides · 93% winter drop  
**Action:** Launch "Weekend Rider → Annual Member" upgrade offer May–August. Target casuals riding 3+ times in 30 days via in-app push. Physical promotions at top casual stations Fri–Sun.  
**Impact:** 5% conversion of 1.95M casuals = **~97,500 new annual members**

→ Supported by: Findings 2 + 3 · `visualizations/rides_by_day.png` · `visualizations/monthly_trends.png`

---

### Recommendation 2 — Point-of-Use Digital Ads at Casual Hotspot Stations `HIGH PRIORITY`
**Evidence:** Top 3 stations = 81,313 rides · All tourist/leisure locations · High casual concentration  
**Action:** QR-code displays at top 10 casual stations. Message: "You've spent $X today — membership pays for itself in 8 rides." Link to 60-second mobile sign-up.  
**Impact:** Highest-conversion touchpoint — captured at moment of maximum purchase intent

→ Supported by: Finding 4 · `visualizations/station_map.png` · `data/analyzed/top_stations.csv`

---

### Recommendation 3 — Reframe Membership as Leisure Lifestyle `MEDIUM PRIORITY`
**Evidence:** 19.2 min avg casual ride · 28.7 min classic bike · Tourist station clustering  
**Action:** Replace commuter-centric messaging with leisure lifestyle: "Ride longer. Explore more. Pay less." Lakefront imagery. Deploy on Instagram + TikTok.  
**Impact:** Changes the value proposition for 1.95M leisure-first riders

→ Supported by: Findings 1 + 4 + 5 · `visualizations/avg_ride_length.png` · `visualizations/bike_type_usage.png`

---

## 🗂 File Cross-Reference Map

| Finding | SQL Query | Visualization | Data File |
|---------|-----------|---------------|-----------|
| Ride Duration | `sql/03_analysis_queries.sql` Analysis 1 | `visualizations/avg_ride_length.png` | `data/analyzed/ride_length_summary.csv` |
| Weekly Patterns | `sql/03_analysis_queries.sql` Analysis 2 | `visualizations/rides_by_day.png` | `data/analyzed/rides_by_day.csv` |
| Seasonal Trends | `sql/03_analysis_queries.sql` Analysis 3 | `visualizations/monthly_trends.png` | `data/analyzed/monthly_trends.csv` |
| Station Geography | `sql/03_analysis_queries.sql` Analysis 4B | `visualizations/station_map.png` | `data/analyzed/top_stations.csv` |
| Bike Type | `sql/03_analysis_queries.sql` Analysis 5 | `visualizations/bike_type_usage.png` | `data/analyzed/bike_type_usage.csv` |
| Peak Hour (Bonus) | `sql/03_analysis_queries.sql` Analysis 6 | *(in Tableau dashboard)* | *(derived from all_trips_clean)* |
| Cleaning decisions | `sql/01_data_cleaning.sql` | — | `documentation/data_cleaning_log.md` |
| Challenges | — | — | `documentation/challenges_and_solutions.md` |

---

## ⚠️ Limitations

1. **No user-level data** — cannot track individual casual riders across multiple trips (privacy)
2. **No pricing data** — cannot calculate revenue or ROI for recommendations
3. **No demographic data** — cannot segment casuals by tourist vs local, age, or income
4. **12-month snapshot** — seasonal patterns assumed to repeat; cannot measure YoY trends
5. **No competitor data** — cannot assess whether casuals use competing services

---

*Last updated: May 2026 · Nikhilvarma Kandula · Google Data Analytics Capstone*  
*Full project: github.com/kandulanikhilvarma/cyclistic-bikeshare-case-study*
