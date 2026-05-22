-- celsius_to_fahrenheit.sql
-- Converts Celsius to Fahrenheit
-- Usage: {{ celsius_to_fahrenheit('temp_max_c') }}
-- Formula: (C × 9/5) + 32

{% macro celsius_to_fahrenheit(column_name) %}
    round(({{ column_name }} * 9.0/5.0 + 32)::numeric, 1)
{% endmacro %}