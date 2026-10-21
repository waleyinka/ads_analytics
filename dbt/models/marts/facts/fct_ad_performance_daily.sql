-- Path: models/marts/facts/fct_ad_performance_daily.sql
-- Grain: one row per platform, ad_id and ad_date.


{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='ad_performance_key',
        on_schema_change='fail'
    )
}}

WITH source AS (

    SELECT *
    FROM {{ ref('int_ads__ad_stats_unioned') }}

    {% if is_incremental() %}
    -- Reprocess the last N days relative to what is already loaded.
    -- coalesce guards the edge case of an existing but empty table.
    WHERE ad_date >= (
        SELECT date_sub (
            coalesce(max(ad_date), CAST('1900-01-01' AS DATE)),
            {{ var('lookback_days', 3) }}
        )
        FROM {{ this }}
    )
    {% endif %}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['platform', 'ad_id', 'ad_date']) }}            AS ad_performance_key,
        {{ dbt_utils.generate_surrogate_key(['platform', 'campaign_id']) }}                 AS campaign_key,
        platform,
        ad_id,
        ad_date,
        campaign_id,
        ad_group_id,
        currency_code,
        spend,
        spend_eur,
        impressions,
        clicks,
        is_clicks_reported,
        current_timestamp()                          as _loaded_at   -- when this row was last written
    from source

)

select * from final