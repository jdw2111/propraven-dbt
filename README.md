# propraven-dbt

The dbt package for the [PropRaven](https://propraven.com) Snowflake Marketplace shares (`PROPRAVEN_CORE`, `PROPRAVEN_OWNER_GRAPH`, `PROPRAVEN_INSURANCE`, `PROPRAVEN_PREVIEW`).

Drop it into any dbt project that has the PropRaven share mounted and you get:

- Typed `sources:` for every shared `SILVER.*` / `META.*` / `GOLD.*` table
- Pre-built `stg_propraven__{parcels,permits,transactions,owners,geography}` views with lowercase columns and the conventions you'd expect
- Two worked-example marts (`parcels_with_recent_activity`, `owner_portfolio_summary`)
- A `check_propraven_freshness` operation that surfaces stale silver entities
- A `generate_propraven_sources` codegen-style macro that re-emits the sources block when the share's table list changes

## Requirements

- dbt-core 1.7+
- Snowflake adapter
- An accepted PropRaven Snowflake Marketplace share (default mount: `PROPRAVEN.SILVER.*`)

## Install

In your project's `packages.yml`:

```yaml
packages:
  - git: "https://github.com/jdw2111/propraven-dbt.git"
    revision: v0.1.0
```

Then:

```bash
dbt deps
```

Or via dbt Hub once the package is published:

```yaml
packages:
  - package: propraven/propraven
    version: [">=0.1.0", "<0.2.0"]
```

## Configure

Override these vars in your own `dbt_project.yml` if your share landed under a non-default database/schema:

```yaml
vars:
  propraven_database: "PROPRAVEN"         # the database the share mounted as
  propraven_silver_schema: "SILVER"       # parcels, properties, permits, etc.
  propraven_meta_schema: "META"           # SOURCE_LINEAGE, ENTITY_DICTIONARY
  propraven_gold_schema: "GOLD"           # ABSENTEE, INSTITUTIONAL, etc. (optional)
  propraven_insurance_schema: "INSURANCE" # PROPRAVEN_INSURANCE share (optional)
```

## Use

```bash
# Build the staging + mart models
dbt run --select propraven

# Run schema tests against the share
dbt test --select source:propraven_silver

# Check that the share is fresh
dbt run-operation check_propraven_freshness --args '{warn_after_hours: 168}'

# Re-generate sources after a share schema change
dbt run-operation generate_propraven_sources --args '{schemas: ["SILVER","META"]}'
```

## Worked examples

`models/marts/parcels_with_recent_activity.sql` joins each parcel to its most recent permit and most recent arm's-length sale — a common starting point for monitoring portfolios.

`models/marts/owner_portfolio_summary.sql` rolls parcels up by `owner_entity_id`, summing assessed value across each entity's portfolio.

Both marts are designed to be *forked* — they're examples of how to compose the share, not opinionated business logic you should adopt as-is.

## Linking back

Each `stg_propraven__*` view preserves the upstream `last_refreshed_at` column so you can join the share's freshness data directly into your own freshness dashboards.

For full column documentation, see the [PropRaven data dictionary](https://propraven.com/docs) or query `META.ENTITY_DICTIONARY` directly:

```sql
select entity_name, entity_layer, primary_key, expected_row_count
from META.ENTITY_DICTIONARY
order by entity_layer, entity_name;
```

## Issues / contributions

This package is open-source under MIT. File issues or PRs at [github.com/jdw2111/propraven-dbt](https://github.com/jdw2111/propraven-dbt). Substantive changes get co-released with the underlying share refresh.
