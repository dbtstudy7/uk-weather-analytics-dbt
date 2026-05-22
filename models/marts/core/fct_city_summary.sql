-- fct_city_summary.sql
-- Purpose: summary statistics per city enriched with city details
-- Grain: one row per city

with daily as (

    select * from {{ ref('fct_weather_daily') }}

),

cities as (

    select * from {{ ref('dim_cities') }}

),

weather_summary as (

    select
        city_name,
        round(avg(temp_mean_c)::numeric, 1)      as avg_temp_c,
        round(max(temp_max_c)::numeric, 1)        as highest_temp_c,
        round(min(temp_min_c)::numeric, 1)        as lowest_temp_c,
        round(sum(precipitation_mm)::numeric, 1)  as total_rainfall_mm,
        count(case when is_rainy_day then 1 end)  as rainy_days,
        count(case when not is_rainy_day then 1 end) as dry_days,
        round(avg(windspeed_max_kmh)::numeric, 1) as avg_windspeed_kmh,
        round(max(windspeed_max_kmh)::numeric, 1) as max_windspeed_kmh,
        count(*)                                   as total_days

    from daily
    group by city_name

),

final as (

    select
        -- City details from seed
        c.city_name,
        c.country,
        c.region,
        c.population,
        c.is_capital,

        -- Weather summary
        w.avg_temp_c,
        w.highest_temp_c,
        w.lowest_temp_c,
        w.total_rainfall_mm,
        w.rainy_days,
        w.dry_days,
        w.avg_windspeed_kmh,
        w.max_windspeed_kmh,
        w.total_days,

        -- Derived rankings
        rank() over (order by w.avg_temp_c desc)       as warmest_rank,
        rank() over (order by w.total_rainfall_mm desc) as wettest_rank,
        rank() over (order by w.avg_windspeed_kmh desc) as windiest_rank

    from weather_summary w
    left join cities c on w.city_name = c.city_name

)

select * from final
order by warmest_rank