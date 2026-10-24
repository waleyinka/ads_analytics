-- Path: models/intermediate/int_fx_rates__daily.sql
-- Grain: one row per currency_code and rate_date (every calendar day).


with date_spine as (

-- dbt_utils.date_spine: end_date is EXCLUSIVE, so 2026-01-01 includes 2025-12-31.
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ var('fx_start_date', '2024-01-01') ~ "' as date)",
        end_date="cast('" ~ var('fx_end_date', '2026-01-01') ~ "' as date)"
    ) }}

),

seed_rates as (

    select
        rate_date,
        currency_code,
        units_per_eur
    from {{ ref('fx_rates') }}

),

currencies as (

    select distinct currency_code
    from seed_rates

),

-- Every currency on every day; days without a published rate are NULL for now.
calendar as (

    select
        cast(date_spine.date_day as date) as rate_date,
        currencies.currency_code
    from date_spine
    cross join currencies
),

filled as (

    select
        calendar.rate_date,
        calendar.currency_code,
        coalesce(
            -- Forward-fill: last published rate up to this day...
            last_value(seed_rates.units_per_eur, true) over (
                partition by calendar.currency_code
                order by calendar.rate_date
                rows between unbounded preceding and current row
            ),
            -- ...or, for the first days of the range (e.g. 1 Jan, an ECB
            -- holiday), the next published rate.
            first_value(seed_rates.units_per_eur, true) over (
                partition by calendar.currency_code
                order by calendar.rate_date
                rows between current row and unbounded following
            )
        )                                as units_per_eur,
        seed_rates.units_per_eur is null as is_rate_filled
    from calendar
    left join seed_rates
        on
            calendar.rate_date = seed_rates.rate_date
            and calendar.currency_code = seed_rates.currency_code

),

-- EUR -> EUR is always 1.0, on every day.
eur as (

    select
        cast(date_day as date)      as rate_date,
        'EUR'                       as currency_code,
        cast(1.0 as decimal(18, 6)) as units_per_eur,
        false                       as is_rate_filled
    from date_spine

)

select
    rate_date,
    currency_code,
    cast(units_per_eur as decimal(18, 6)) as units_per_eur,
    is_rate_filled
from filled

union all

select
    rate_date,
    currency_code,
    units_per_eur,
    is_rate_filled
from eur
