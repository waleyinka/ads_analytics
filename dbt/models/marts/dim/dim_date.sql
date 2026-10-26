-- Grain: one row per calendar day, covering both platforms' data (2024-2025).
-- Lets analysts and AI agents answer "last month" or "by week" consistently.

with spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ var('fx_start_date') ~ "' as date)",
        end_date="cast('" ~ var('fx_end_date') ~ "' as date)"
    ) }}

),

final as (

    select
        cast(date_day as date)                      as date_day,
        year(date_day)                              as year,
        quarter(date_day)                           as quarter,
        month(date_day)                             as month,
        date_format(date_day, 'MMMM')               as month_name,
        cast(date_trunc('month', date_day) as date) as month_start,
        cast(date_trunc('week', date_day) as date)  as week_start,     -- Monday
        dayofweek(date_day) in (1, 7)               as is_weekend      -- 1 = Sunday
    from spine
)

select * from final
