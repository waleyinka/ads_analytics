-- Grain: one row per calendar day, covering both platforms' data (2024-2025).
-- Lets analysts and AI agents answer "last month" or "by week" consistently.

WITH spine AS (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ var('fx_start_date') ~ "' as date)",
        end_date="cast('" ~ var('fx_end_date') ~ "' as date)"
    ) }}

),

final AS (

    SELECT
        CAST(date_day AS date)                       AS date_day,
        year(date_day)                               AS year,
        quarter(date_day)                            AS quarter,
        month(date_day)                              AS month,
        date_format(date_day, 'MMMM')                AS month_name,
        CAST(date_trunc('month', date_day) AS date)  AS month_start,
        CAST(date_trunc('week', date_day) AS date)   AS week_start,     -- Monday
        dayofweek(date_day) IN (1, 7)                AS is_weekend      -- 1 = Sunday
    FROM spine
)

SELECT * FROM final