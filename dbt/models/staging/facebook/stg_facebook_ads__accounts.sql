-- Path: /dbt/models/staging/facebook/stg_facebook_ads__accounts.sql
-- Grain: one row per account_id.

with source_data as (

    select * from {{ source('facebook_ads', 'accounts') }}

),

formatted as (
    -- Formatting columns
    select
        cast(account_id as string)            as account_id,
        cast(account_name as string)          as account_name,

        cast(ad_currency_code as string)      as ad_currency_code,

        cast(account_created_at as timestamp) as account_created_at,
        cast(account_updated_at as timestamp) as account_updated_at
    from source_data
)

select * from formatted
