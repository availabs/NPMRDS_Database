# PM3 Calculator Data Provences and TMC Metadata Versions

**TL;DR**: Versioned derivative PM3 data sources depend on the existence of
versioned _tmc_identification_ and _tmc_metadata_ tables in the database, as
well as those tables' naming schemes. Renaming or removing the
_tmc_identification_ and _tmc_metadata_ tables will require changing
how we compute versioned derivative PM3 data sources.

See [[Centralizing NPMRDS Table Partitions]]

## Explanation

The PM3 calculator persists only the TMC metadata used in a given calculation
run. Downstream measures, such as the versioned aggregate geography level
measures, depend upon both the versioned PM3 calculations and versioned TMC
metadata columns potentially beyond what the PM3 calculator persists. To
provide consistent calculations we must provide a consistent snapshot of the
TMC metadata at the time of the PM3 measure calculations.

Currently, we handle this requirement in a PostgreSQL function that
executes a dynamic SQL query that uses the timestamps on the versioned
_tmc_identification_ tables to determine which _tmc_metadata_ version was
active when the calculation run. This method is complex, brittle, and forces
us to keep all _tmc_identification_ and _tmc_metadata_ tables. If a table
is missing, the dynamic SQL query fails.

### Database

- [pm3.pm3_calculator_data_provenances](https://github.com/availabs/NPMRDS_Database/blob/504deaf5f4dec0b4deb6ff46e538246cfd0703e1/sql/pm3_calculator_data_provenances/create_pm3_calculator_data_provenances_views.sql)

- [pm3.pm3_versioned_tmc_metadata_fn](https://github.com/availabs/NPMRDS_Database/blob/276f252fe76964bc8974faa8fe416b5a6acda7cf/sql/pm3_versioned_tmc_metadata_fn/create_pm3_versioned_tmc_metadata_fn.sql)

- [pm3.create_pm3_calculation_versions_db_objects.sql](https://github.com/availabs/NPMRDS_Database/blob/276f252fe76964bc8974faa8fe416b5a6acda7cf/sql/pm3_calculation_versions/create_pm3_calculation_versions_db_objects.sql)

- [pm3.calculate_pm3_geolevel_calculation_version_v1_1](https://github.com/availabs/NPMRDS_Database/blob/276f252fe76964bc8974faa8fe416b5a6acda7cf/sql/pm3_geolevel_calculation_versions/create_calculate_pm3_geolevel_calculation_version_fn.v1_1.sql)

- [pm3.calculate_pm3_geolevel_calculation_version_v1_2](https://github.com/availabs/NPMRDS_Database/blob/276f252fe76964bc8974faa8fe416b5a6acda7cf/sql/pm3_geolevel_calculation_versions/create_calculate_pm3_geolevel_calculation_version_fn.v1_2.sql)

### API

- avail-falcor/services/pm3MeasuresController/versionedGeoLevelPm3MeasuresDAO.js
  - [getTmcsInGeographyForPm3CalcVersions](https://github.com/availabs/avail-falcor/blob/7105a984825dbc23d1eda5ebdc02975d2731fb59/services/pm3MeasuresController/versionedGeoLevelPm3MeasuresDAO.js#L215)
  - [getGeographyAggregateRoadStatsForVersions](https://github.com/availabs/avail-falcor/blob/7105a984825dbc23d1eda5ebdc02975d2731fb59/services/pm3MeasuresController/versionedGeoLevelPm3MeasuresDAO.js#L303)

[centralizing npmrds table partitions]: ./centralizing_npmrds_table_partitions.md
[pm3 calculator data provences and tmc metadata versions]: ./pm3-calculator-data-provences-and-tmc-metadata-versions.md

## Backlinks

- [[Centralizing NPMRDS Table Partitions]]
  - Note, however, the PM3 data sources have dependencies on the existence and
    ([[PM3 Calculator Data Provences and TMC Metadata Versions]])
    and some application code may refer to the \*npmrds\* table partitions directly.
