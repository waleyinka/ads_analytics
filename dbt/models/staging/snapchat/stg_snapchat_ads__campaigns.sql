-- Path: /dbt/models/staging/snapchat/stg_snapchat_ads__campaigns.sql
-- Grain: one row per campaign_id.

with source_data as (

    select * from {{ source('snapchat_ads', 'campaigns') }}

),

formatted as (
    -- Formatting columns
    select
        cast(campaign_id as string)   as campaign_id,
        cast(account_id as string)    as account_id,
        cast(campaign_name as string) as campaign_name
    from source_data
)

select * from formatted
