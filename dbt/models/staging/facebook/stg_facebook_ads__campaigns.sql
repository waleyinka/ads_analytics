-- Path: /dbt/models/staging/facebook/stg_facebook_ads__campaigns.sql
-- Grain: one row per campaign_id

with source_data as (

    select * from {{ source('facebook_ads', 'campaigns') }}

),

formatted as (
    -- Formatting columns
    select
        cast(campaign_id as string)            as campaign_id,
        cast(campaign_name as string)          as campaign_name,

        cast(campaign_updated_at as timestamp) as campaign_updated_at
    from source_data
)

select * from formatted
