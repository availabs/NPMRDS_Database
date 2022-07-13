# Centralizing NPMRDS Table Partitions

Currently, the _npmrds_ table partitions and the _tmc_identification_ and
_tmc_metadata_ table versions are all in the state (_nj_, _ny_, etc) schemas.

To clean up the database and make it easier for users to explore and comprehend
the published data tables, we should move the partition and version tables into
an _\_npmrds_admin_partitions_ schema.

Note, however, the PM3 data sources have dependencies on the existence and
naming of the versioned _tmc_identification_ and _tmc_metadata_ tables
([[PM3 Calculator Data Provences and TMC Metadata Versions]])
and some application code may refer to the _npmrds_ table partitions directly.

[pm3 calculator data provences and tmc metadata versions]: ./pm3-calculator-data-provences-and-tmc-metadata-versions.md
[centralizing npmrds table partitions]: ./centralizing_npmrds_table_partitions.md

## Backlinks

- [[PM3 Calculator Data Provences and TMC Metadata Versions]]
  - See [[Centralizing NPMRDS Table Partitions]]
