-- Safely deletes a pull request’s CI schemas

{#
    Drops one pull request's CI schemas: <schema_name> and <schema_name>_*
    (e.g. ci_pr_42, ci_pr_42_staging, ci_pr_42_marts ...).

    Two guards, because this macro runs DROP ... CASCADE:
      1. Only against the ci target, never dev or prod.
      2. Only schemas whose name starts with ci_pr_.
    The "|" pattern matches ci_pr_42 and ci_pr_42_* but NOT ci_pr_420.
#}

{% macro drop_ci_schemas(schema_name) %}

    {% if target.name != 'ci' %}
        {{ exceptions.raise_compiler_error("drop_ci_schemas only runs against the ci target, not '" ~ target.name ~ "'") }}
    {% endif %}

    {% if not schema_name.startswith('ci_pr_') %}
        {{ exceptions.raise_compiler_error("Refusing to drop schemas not starting with ci_pr_: " ~ schema_name) }}
    {% endif %}

    {% set pattern = schema_name ~ "|" ~ schema_name ~ "_*" %}
    {% set schemas = run_query("show schemas in " ~ target.database ~ " like '" ~ pattern ~ "'") %}

    {% for row in schemas.rows %}
        {% set fqn = target.database ~ "." ~ row[0] %}
        {{ log("Dropping " ~ fqn, info=True) }}
        {% do run_query("drop schema if exists " ~ fqn ~ " cascade") %}
    {% endfor %}

    {{ log("Dropped " ~ schemas.rows | length ~ " schema(s) for " ~ schema_name, info=True) }}

{% endmacro %}