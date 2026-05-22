# 🌦️ UK Weather Analytics — dbt Pipeline

A production-grade data pipeline built with **dbt Core** and **Python**
that ingests real UK weather data from the Open-Meteo API and transforms
it into business-ready analytics.

## 🏗️ Architecture

## 📊 What This Pipeline Does

Fetches **91 days of real weather data** for 5 UK cities and answers:
- 🌡️ Which city was warmest? → **London (avg 9.6°C)**
- ☔ Which city had most rain? → **Manchester (180mm)**
- 💨 Which city was windiest? → **Edinburgh (avg 18.1 km/h)**
- ☀️ Which city was driest? → **London (53 dry days)**

## 🏙️ Cities Covered

| City | Country | Region |
|------|---------|--------|
| London | England | South East |
| Manchester | England | North West |
| Birmingham | England | West Midlands |
| Edinburgh | Scotland | Scotland |
| Cardiff | Wales | Wales |

## 🗂️ Project Structure
├── scripts/
│   └── fetch_weather.py        # Python — fetches data from API
├── seeds/
│   └── dim_cities.csv          # City metadata — region, population
├── models/
│   ├── staging/
│   │   └── weather/
│   │       └── stg_weather__daily.sql   # Clean raw data
│   └── marts/
│       └── core/
│           ├── fct_weather_daily.sql    # Daily facts per city
│           └── fct_city_summary.sql     # City rankings + summary
├── snapshots/
│   └── cities_snapshot.sql     # SCD Type 2 on city data
├── macros/
│   └── celsius_to_fahrenheit.sql # Reusable temp conversion
└── packages.yml                # dbt_utils + dbt_expectations
## 📐 Data Model
raw.weather_daily (API source)
↓
stg_weather__daily (cleaned, nulls handled)
↓
fct_weather_daily (455 rows — daily facts + categories)
↓
fct_city_summary (5 rows — city rankings)
##Data Quality
## ✅ Data Quality

**9 automated tests** including:
- `not_null` on all key columns
- `accepted_values` — only valid UK cities
- `expect_table_row_count_to_be_between` — catches empty pipeline
- `expect_column_values_to_be_between` — temperature range -20°C to 45°C
- `expect_column_values_to_be_between` — precipitation 0 to 200mm

## 🔧 Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| dbt Core | 1.11.8 | Data transformation |
| Python | 3.10 | Data ingestion |
| PostgreSQL | 18 | Local data warehouse |
| dbt_utils | 1.1.1 | Utility macros |
| dbt_expectations | 0.10.4 | Advanced data quality |

## 🚀 How to Run

**1. Fetch raw data:**
```bash
python scripts/fetch_weather.py
```

**2. Run full pipeline:**
```bash
dbt build
```

**3. View documentation:**
```bash
dbt docs generate && dbt docs serve
```

## 📈 Key Insights (Feb–May 2026)

| City | Avg Temp | Total Rain | Rainy Days | Warmest Rank |
|------|----------|------------|------------|-------------|
| London | 9.6°C | 44.6mm | 38 | 🥇 1st |
| Cardiff | 9.1°C | 117.2mm | 39 | 🥈 2nd |
| Birmingham | 8.5°C | 104.8mm | 42 | 🥉 3rd |
| Manchester | 8.4°C | 180.0mm | 48 | 4th |
| Edinburgh | 7.3°C | 116.2mm | 48 | 5th |

## 👤 Author

Built as part of a Lead Data Engineer learning portfolio.
Stack: dbt · Python · PostgreSQL · AWS (coming soon)