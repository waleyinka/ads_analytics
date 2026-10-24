{% docs __overview__ %}
# Marketing Data Platform

Facebook Ads and Snapchat Ads performance, unified into one governed, tested and documented model for analysts, BI tools and AI agents.

## Start here
| Question | Use |
|---|---|
| Spend, clicks, CTR/CPC/CPM by campaign or platform | `marketing_performance_daily` (campaign × day) |
| Ad-level detail or custom aggregation | `fct_ad_performance_daily` (platform × ad × day) |
| Campaign names and accounts | `dim_campaign` |
| Week, month, quarter | `dim_date` |

## Things to know before querying
- **Currency:** Facebook spend is in USD or EUR depending on the account. Use `spend_eur` for any cross-account or cross-platform total.
- **Coverage:** Facebook covers 2025-01-01 to 2025-12-31; Snapchat covers 2024-01-01 to 2024-12-02. The platforms do not overlap in time.
- **Ratios:** CTR, CPC and CPM are valid only at the grain of the model they live in. Recompute them from summed totals for any other grouping.

## Layers
`raw (ads_raw)` → `staging` (clean, typed, 1:1 with sources) → `intermediate` (enrich, re-grain, combine, FX) → `marts` (facts, dimensions, reporting).
{% enddocs %}