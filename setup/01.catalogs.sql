-- Create catalog only if catalog with same name doesn't exist.
CREATE CATALOG IF NOT EXISTS marketing_data;

-- Create schema only if schema with same name doesn't exist.
CREATE SCHEMA IF NOT EXISTS marketing_data.ads_raw;

-- Production catalog: written only by the service principal via dbt.
-- dbt creates the schemas inside it on the first prod run.
CREATE CATALOG IF NOT EXISTS marketing_prod
  COMMENT 'Production marketing data platform. Written only by sp-ads-analytics-prod via dbt.';