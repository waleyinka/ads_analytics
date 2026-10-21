-- Path: models/intermediate/int_fx_rates__daily.sql
-- Grain: one row per currency_code and rate_date (every calendar day).


WITH date_spine AS (

    -- dbt_utils.date_spine: end_date is EXCLUSIVE, so 2026-01-01 includes 2025-12-31.
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ var('fx_start_date', '2024-01-01') ~ "' as date)",
        end_date="cast('" ~ var('fx_end_date', '2026-01-01') ~ "' as date)"
    ) }}

),

seed_rates AS (

    SELECT rate_date, currency_code, units_per_eur
    FROM {{ ref('fx_rates') }}

),

currencies AS (

    SELECT
        DISTINCT currency_code 
    FROM seed_rates

),

-- Every currency on every day; days without a published rate are NULL for now.
calendar AS (

    SELECT
        CAST(date_spine.date_day AS DATE)            AS rate_date,
        currencies.currency_code
    FROM date_spine
    CROSS JOIN currencies
),

filled AS (

    SELECT
        calendar.rate_date,
        calendar.currency_code,
        coalesce(
            -- Forward-fill: last published rate up to this day...
            last_value(seed_rates.units_per_eur, true) OVER (
                PARTITION BY calendar.currency_code
                ORDER BY calendar.rate_date
                ROWS BETWEEN UNBOUNDED PRECEDING AND current ROW
            ),
            -- ...or, for the first days of the range (e.g. 1 Jan, an ECB
            -- holiday), the next published rate.
            first_value(seed_rates.units_per_eur, true) OVER (
                PARTITION BY calendar.currency_code
                ORDER BY calendar.rate_date
                ROWS BETWEEN current ROW AND UNBOUNDED FOLLOWING
            )
        )                                            AS units_per_eur,
        seed_rates.units_per_eur IS NULL             AS is_rate_filled
    FROM calendar
    LEFT JOIN seed_rates
        ON calendar.rate_date = seed_rates.rate_date
       AND calendar.currency_code = seed_rates.currency_code

),

-- EUR -> EUR is always 1.0, on every day.
eur AS (

    SELECT
        CAST(date_day AS date)                       AS rate_date,
        'EUR'                                        AS currency_code,
        CAST(1.0 AS decimal(18, 6))                  AS units_per_eur,
        false                                        AS is_rate_filled
    FROM date_spine

)

SELECT
    rate_date, currency_code,
    CAST(units_per_eur AS decimal(18, 6)) AS units_per_eur,
    is_rate_filled
FROM filled

UNION ALL

SELECT
    rate_date,
    currency_code,
    units_per_eur,
    is_rate_filled
FROM eur
