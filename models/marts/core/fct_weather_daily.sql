-- fct_weather_daily.sql
-- Purpose: daily weather fact table
-- Grain: one row per city per day
-- Business questions answered:
--   - What was London's temperature on a specific date?
--   - How many rainy days did Manchester have?
--   - Which city was coldest last week?

with weather as (

    select * from {{ ref('stg_weather__daily') }}

),

final as (

    select
        -- Keys
        city_name,
        date,

        -- Temperature measures
        -- Fahrenheit conversions using macro
{{ celsius_to_fahrenheit('temp_max') }}    as temp_max_f,
{{ celsius_to_fahrenheit('temp_min') }}    as temp_min_f,
{{ celsius_to_fahrenheit('temp_mean') }}   as temp_mean_f,
        round((temp_max - temp_min)::numeric, 2)   as temp_range_c,

        -- Precipitation
        precipitation_mm,
        case
            when precipitation_mm > 0 then true
            else false
        end                                         as is_rainy_day,

        -- Wind
        windspeed_max_kmh,
        case
            when windspeed_max_kmh >= 50 then 'Storm'
            when windspeed_max_kmh >= 30 then 'Windy'
            when windspeed_max_kmh >= 15 then 'Breezy'
            else 'Calm'
        end                                         as wind_category,

        -- Temperature category
        case
            when temp_mean >= 20 then 'Hot'
            when temp_mean >= 15 then 'Warm'
            when temp_mean >= 10 then 'Mild'
            when temp_mean >= 5  then 'Cool'
            else 'Cold'
        end                                         as temp_category,

        -- Date parts
        extract(month from date)                    as month_num,
        extract(year from date)                     as year_num,
        to_char(date, 'Month')                      as month_name,
        to_char(date, 'Day')                        as day_name,

        -- Metadata
        loaded_at

    from weather

)

select * from final