# fetch_weather.py
# Fetches real UK weather data from Open-Meteo API
# Free — no API key needed

import requests
import psycopg2
from datetime import datetime, timedelta

# UK Cities
CITIES = [
    {"name": "London",     "lat": 51.5074, "lon": -0.1278},
    {"name": "Manchester", "lat": 53.4808, "lon": -2.2426},
    {"name": "Birmingham", "lat": 52.4862, "lon": -1.8904},
    {"name": "Edinburgh",  "lat": 55.9533, "lon": -3.1883},
    {"name": "Cardiff",    "lat": 51.4816, "lon": -3.1791},
]

# Last 90 days
end_date   = datetime.now().strftime("%Y-%m-%d")
start_date = (datetime.now() - timedelta(days=90)).strftime("%Y-%m-%d")

print(f"Fetching weather from {start_date} to {end_date}")
print(f"Cities: {[c['name'] for c in CITIES]}")
print("-" * 50)

# ── Fetch from API ──────────────────────────────
def fetch_city_weather(city):
    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude":  city["lat"],
        "longitude": city["lon"],
        "daily": [
            "temperature_2m_max",
            "temperature_2m_min",
            "temperature_2m_mean",
            "precipitation_sum",
            "windspeed_10m_max",
            "weathercode"
        ],
        "timezone":   "Europe/London",
        "start_date": start_date,
        "end_date":   end_date
    }
    response = requests.get(url, params=params)
    if response.status_code == 200:
        print(f"✅ {city['name']} — fetched successfully")
        return response.json()
    else:
        print(f"❌ {city['name']} — failed: {response.status_code}")
        return None

# ── Connect to Postgres ─────────────────────────
import os

def get_connection():
    return psycopg2.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        database="postgres",
        user="postgres",
        password=os.environ.get("DB_PASSWORD", "Jaya@123"),
        port=5432
    )
# ── Create raw table ────────────────────────────
def create_table(conn):
    cur = conn.cursor()
    cur.execute("CREATE SCHEMA IF NOT EXISTS raw;")
    cur.execute("""
        DROP TABLE IF EXISTS raw.weather_daily;
        CREATE TABLE raw.weather_daily (
            id            SERIAL PRIMARY KEY,
            city_name     VARCHAR(50),
            latitude      DECIMAL(8,4),
            longitude     DECIMAL(8,4),
            date          DATE,
            temp_max      DECIMAL(5,2),
            temp_min      DECIMAL(5,2),
            temp_mean     DECIMAL(5,2),
            precipitation DECIMAL(6,2),
            windspeed_max DECIMAL(6,2),
            weathercode   INTEGER,
            loaded_at     TIMESTAMP DEFAULT NOW()
        );
    """)
    conn.commit()
    print("✅ raw.weather_daily table created")

# ── Insert data ─────────────────────────────────
def insert_data(conn, city, data):
    cur = conn.cursor()
    daily = data["daily"]
    count = 0
    for i, date in enumerate(daily["time"]):
        cur.execute("""
            INSERT INTO raw.weather_daily (
                city_name, latitude, longitude, date,
                temp_max, temp_min, temp_mean,
                precipitation, windspeed_max, weathercode
            ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            city["name"], city["lat"], city["lon"], date,
            daily["temperature_2m_max"][i],
            daily["temperature_2m_min"][i],
            daily["temperature_2m_mean"][i],
            daily["precipitation_sum"][i],
            daily["windspeed_10m_max"][i],
            daily["weathercode"][i]
        ))
        count += 1
    conn.commit()
    print(f"   {count} rows inserted for {city['name']}")
    return count

# ── Main ────────────────────────────────────────
def main():
    print("\nConnecting to Postgres...")
    conn = get_connection()
    print("✅ Connected")

    print("\nCreating raw table...")
    create_table(conn)

    print("\nFetching and loading data...")
    total = 0
    for city in CITIES:
        data = fetch_city_weather(city)
        if data:
            total += insert_data(conn, city, data)

    conn.close()
    print("\n" + "="*50)
    print(f"✅ DONE — {total} rows loaded into raw.weather_daily")
    print("="*50)

if __name__ == "__main__":
    main()