-- Auto-generate a sources block from the Snowflake share's INFORMATION_SCHEMA.
-- Inspired by dbt-labs/codegen — but scoped to the PropRaven share so you
-- get the same output even before you've added codegen to your deps.
--
-- Usage:
--   dbt run-operation generate_propraven_sources \
--     --args '{schemas: ["SILVER","META","GOLD"]}'
--
-- Pipe the output into a fresh `_sources.yml`. Designed for re-running after
-- a share refresh that adds/removes tables.

{% macro generate_propraven_sources(schemas=['SILVER', 'META']) %}

    {% set db = var('propraven_database', 'PROPRAVEN') %}
    {% set yaml_lines = [] %}
    {% do yaml_lines.append("version: 2") %}
    {% do yaml_lines.append("") %}
    {% do yaml_lines.append("sources:") %}

    {% for schema in schemas %}
        {% set src_name = 'propraven_' ~ schema | lower %}
        {% do yaml_lines.append("  - name: " ~ src_name) %}
        {% do yaml_lines.append("    database: " ~ db) %}
        {% do yaml_lines.append("    schema: " ~ schema) %}
        {% do yaml_lines.append("    tables:") %}

        {% set q %}
            select table_name
            from {{ db }}.INFORMATION_SCHEMA.TABLES
            where table_schema = '{{ schema }}'
              and table_type in ('BASE TABLE','VIEW')
            order by table_name
        {% endset %}

        {% set tables = run_query(q) %}
        {% if execute %}
            {% for row in tables.rows %}
                {% do yaml_lines.append("      - name: " ~ row[0]) %}
            {% endfor %}
        {% endif %}
    {% endfor %}

    {% if execute %}
        {{ log("\n" ~ yaml_lines | join("\n") ~ "\n", info=True) }}
    {% endif %}

{% endmacro %}
