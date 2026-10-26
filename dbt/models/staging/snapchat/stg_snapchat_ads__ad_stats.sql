-- Path: /dbt/models/staging/snapchat/stg_snapchat_ads__ad_stats.sql
-- Grain: one row per ad_id, ad_date and country_code.

with source_data as (

    select * from {{ source('snapchat_ads', 'ad_stats') }}

),

formatted as (
    -- Formatting columns
    select
        cast(ad_detail_id as string)              as ad_id,
        cast(ad_date as date)                     as ad_date,
        cast(ad_country as string)                as country_code,
        cast(ad_currency_code as string)          as currency_code,

        cast(ad_spend as decimal(18, 6))          as spend,

        cast(ad_impressions as bigint)            as impressions,

        cast(nullif(ad_clicks, 'null') as bigint) as clicks_raw
    from source_data
),

cleaned as (
    select
        'snapchat'              as platform,
        ad_id,
        ad_date,
        country_code,
        currency_code,
        spend,
        impressions,
        coalesce(clicks_raw, 0) as clicks,
        clicks_raw is not null  as is_clicks_reported
    from formatted
)

select * from cleaned
