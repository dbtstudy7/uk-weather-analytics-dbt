-- cities_snapshot.sql
-- Purpose: track changes to city data over time
-- SCD Type 2 — keeps full history of every change
-- Example: if London population is updated — old value preserved

{% snapshot cities_snapshot %}

    {{
        config(
            target_schema='snapshots',
            unique_key='city_name',
            strategy='check',
            check_cols=['population', 'region', 'country']
        )
    }}

    select * from {{ ref('dim_cities') }}

{% endsnapshot %}