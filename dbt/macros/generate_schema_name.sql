{#
    Schema naming per environment:
      prod      -> custom schema as-is:          marts
      dev / ci  -> prefixed with target schema:  dbt_omowale_marts, ci_pr_42_marts
    The prefix keeps every developer and every pull request isolated; prod
    gets clean names because it's the only environment consumers read.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- elif target.name == 'prod' -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}