-- stg_weather__daily.sql
-- Purpose: clean raw weather data from Open-Meteo API
-- Grain: one row per city per day
-- Rule: clean only — no joins, no calculations

with source as (

    select * from {{ source('raw', 'weather_daily') }}

),

cleaned as (

    select
        -- Identity
        id,
        city_name,
        date,

        -- Temperature columns — handle nulls with coalesce
        coalesce(temp_max, temp_min, temp_mean)  as temp_max,
        coalesce(temp_min, temp_max, temp_mean)  as temp_min,
        coalesce(temp_mean,
            (coalesce(temp_max, 0) + coalesce(temp_min, 0)) / 2
        )                                         as temp_mean,

        -- Precipitation — null means no rain = 0
        coalesce(precipitation, 0)               as precipitation_mm,

        -- Wind
        coalesce(windspeed_max, 0)               as windspeed_max_kmh,

        -- Weather code
        weathercode,

        -- Metadata
        loaded_at

    from source
    where city_name is not null
    and date is not null

)

select * from cleaned