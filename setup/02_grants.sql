-- =============================================================================
-- Unity Catalog grants for the ads_analytics project.
-- Replace <sp-application-id> with the service principal's Application ID.
-- Principle: each identity gets only what its job needs.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Service principal: READ raw data
-- -----------------------------------------------------------------------------
-- USE CATALOG / USE SCHEMA let it "see" the containers; SELECT lets it read.
-- It gets nothing else in marketing_data: no writes, no access to dev schemas.
GRANT USE CATALOG ON CATALOG marketing_data           TO `f915432c-9c51-459a-9354-0ef437f314e6`;
GRANT USE SCHEMA  ON SCHEMA  marketing_data.ads_raw   TO `f915432c-9c51-459a-9354-0ef437f314e6`;
GRANT SELECT      ON SCHEMA  marketing_data.ads_raw   TO `f915432c-9c51-459a-9354-0ef437f314e6`;


-- -----------------------------------------------------------------------------
-- 2. Service principal: BUILD production
-- -----------------------------------------------------------------------------
-- CREATE SCHEMA lets dbt create staging, intermediate, marts, seeds and
-- elementary. The SP then OWNS those schemas, and an owner has full rights on
-- its own objects, so no CREATE TABLE / MODIFY grants are needed.
GRANT USE CATALOG   ON CATALOG marketing_prod TO `f915432c-9c51-459a-9354-0ef437f314e6`;
GRANT CREATE SCHEMA ON CATALOG marketing_prod TO `f915432c-9c51-459a-9354-0ef437f314e6`;


-- -----------------------------------------------------------------------------
-- 3. Developers: READ-ONLY on production
-- -----------------------------------------------------------------------------
-- The SP owns the prod schemas it creates, so even the catalog owner can't read
-- them without an explicit grant. Developers get read access to inspect and
-- verify prod, but no MODIFY/CREATE: only the SP changes production.
-- Granted on the catalog so it's inherited by every current and future schema.
GRANT USE CATALOG ON CATALOG marketing_prod TO `your-email@example.com`;
GRANT USE SCHEMA  ON CATALOG marketing_prod TO `your-email@example.com`;
GRANT SELECT      ON CATALOG marketing_prod TO `your-email@example.com`;

-- Dev and CI: you own marketing_data, so you already have full rights there.


-- -----------------------------------------------------------------------------
-- 4. Analysts (optional; needs an `analysts` group in your account)
-- -----------------------------------------------------------------------------
-- USE SCHEMA on the catalog lets them see schemas. SELECT on the marts tables
-- is applied by dbt itself via the `grants` config (see dbt_project.yml),
-- so it's re-applied on every prod run.
-- GRANT USE CATALOG ON CATALOG marketing_prod TO `analysts`;
-- GRANT USE SCHEMA  ON CATALOG marketing_prod TO `analysts`;