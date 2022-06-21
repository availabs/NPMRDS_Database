# Create a local development database for TRANSCOM Events -> OSM Mapping

## Instructions

1. Add ./config/postgres.env.prod and ./config/postgres.env.dev files

For example:

```sh
$ cat ./config/postgres.env.dev
PGDATABASE=npmrds_development
PGUSER=postgres
PGPASSWORD=change_this
PGHOST=127.0.0.1
PGPORT=5432
```

2. Update the ./config/env file as needed.

```sh
$ cat config/env
COUNTY_CODE=36001
YEAR=2021
OSM_VERSION=v220101
CONFLATION_VERSION=v0_6_0
```

3. Run the scripts

```sh
./getTableDDL
./getTmcMetadata
./getConflationMapGpkg
./getTranscomEventsExpanded
./getAdminBoundaries
./initializeDevDatabase
./loadAdminBoundaries
./loadTranscomEventsExpanded
./loadConflationMapGpkg
```
