-- Returns rows from META.SOURCE_LINEAGE where the silver entity is older
-- than `warn_after_hours`. Use with dbt-test or invoke from an operation:
--
--   dbt run-operation check_propraven_freshness --args '{warn_after_hours: 168}'
--
-- The marketplace refresh runs monthly, so the default 168h is forgiving.

{% macro check_propraven_freshness(warn_after_hours=168) %}

    {% set query %}
        select
            silver_entity,
            refresh_cadence,
            last_refreshed_at,
            row_count,
            datediff('hour', last_refreshed_at, current_timestamp()) as hours_since_refresh
        from {{ source('propraven_meta', 'SOURCE_LINEAGE') }}
        where datediff('hour', last_refreshed_at, current_timestamp()) > {{ warn_after_hours }}
        order by hours_since_refresh desc
    {% endset %}

    {% set results = run_query(query) %}

    {% if execute %}
        {% if results.rows | length == 0 %}
            {{ log("propraven: all silver entities fresh within " ~ warn_after_hours ~ "h", info=True) }}
        {% else %}
            {{ log("propraven: " ~ (results.rows | length) ~ " stale entities:", info=True) }}
            {% for row in results.rows %}
                {{ log("  - " ~ row[0] ~ " | " ~ row[1] ~ " cadence | " ~ row[4] ~ "h since refresh", info=True) }}
            {% endfor %}
        {% endif %}
    {% endif %}

{% endmacro %}
