{% docs spend %}
Media spend in the original currency of the ad account (see `currency_code`). Facebook accounts report in USD or EUR; Snapchat reports in EUR. **Do not sum across currencies**; use `spend_eur` for any total that spans accounts or platforms.
{% enddocs %}

{% docs spend_eur %}
Media spend converted to EUR: `spend / units_per_eur`, using the ECB daily reference rate for `ad_date`. Weekends and holidays use the last published rate. **The default metric for comparing or totalling spend.**
{% enddocs %}

{% docs impressions %}
Number of times ads were shown. Additive: safe to sum across any rows.
{% enddocs %}

{% docs clicks %}
Number of clicks on ads. Missing source values are counted as 0 (see `is_clicks_reported`). Additive: safe to sum across any rows.
{% enddocs %}

{% docs ctr %}
Click-through rate = `clicks / impressions`, as a fraction (0.0123 = 1.23%). NULL when impressions = 0. **Valid only at this model's grain**: for any other grouping, recompute as `sum(clicks) / sum(impressions)`. Never average this column.
{% enddocs %}

{% docs cpc_eur %}
Cost per click in EUR = `spend_eur / clicks`. NULL when clicks = 0 (undefined, not free). **Valid only at this model's grain**: for any other grouping, recompute as `sum(spend_eur) / sum(clicks)`. Never average this column.
{% enddocs %}

{% docs cpm_eur %}
Cost per 1,000 impressions in EUR = `spend_eur / impressions × 1000`. NULL when impressions = 0. **Valid only at this model's grain**: for any other grouping, recompute as `sum(spend_eur) / sum(impressions) × 1000`. Never average this column.
{% enddocs %}

{% docs platform %}
Advertising platform, lowercase: `facebook` or `snapchat`.
{% enddocs %}

{% docs campaign_key %}
Surrogate key: hash of `platform` + `campaign_id`. Campaign IDs are only unique within a platform, so always join on this key, never on `campaign_id` alone.
{% enddocs %}