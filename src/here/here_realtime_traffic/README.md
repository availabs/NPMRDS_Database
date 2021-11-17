# HERE Realtime Traffic Architecture

## TL;DR

For usage, see:

```sh
./HereRealtimeTrafficEtlService/run --help
```

## HERE Realtime Traffic Scraper & ETL Components

A brief overview of the HERE Realtime Traffic Scraper & ETL Service.

### HereRealtimeTrafficDownloader

- Downloads the HERE Realtime Traffic data from the API on 2 minute intervals
- Disregards stale data downloads
  - Because responses do not have timestamps, stale data is defined as a response
    with the same MD5SUM as the previous response.
- Retries on 1 minute interval if stale data or API error.

For usage, see:

```sh
./HereRealtimeTrafficDownloader/run scrape_here_realtime_traffic --help
```

### HereRealtimeTrafficDatabaseLoader

- Loads the HERE Realtime Traffic API responses into the database.
- Supports
  - Bulk load of files in here_realtime_traffic_data_dir
    - Safely disregards files already loaded into the database.
  - Continuous realtime database updates
- Contains logic to gracefully handle errors and maintain database integrity

### HereRealtimeTrafficEtlService

Composes the HereRealtimeTrafficDownloader and the HereRealtimeTrafficDatabaseLoader.

- On start up, queues the data files in the here_realtime_traffic_data_dir for
  asynchronous database loading.

- Starts the HereRealtimeTrafficDownloader scraping.
  - Scraping runs throughout archived file loading.
  - The ETL Service queues scraper results for loading during this time.
    - Once all queued files are loaded, the ETL Service loads the
      HERE Realtime Traffic API responses in realtime.

For usage, see:

```sh
./HereRealtimeTrafficEtlService/run --help
```

### Logging

Logs are written to _./logs/_. Logs are rotated and compressed.

## Database Schema and Design

**INVARIANT:** HERE Realtime Traffic Data **MUST** be loaded in chronlogical order.
Data that violates this invariant is discarded.

There are two main tables and two views for the HERE Realtime Traffic data.

### public.here_realtime_traffic table

Contains the HERE Realtime Traffic data as downloaded from the API.

```psql
npmrds_production=# \d public.here_realtime_traffic
                    Table "public.here_realtime_traffic"
   Column    |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 tmc         | text                        |           | not null |
 timestamp   | timestamp without time zone |           | not null |
 travel_time | real                        |           | not null |
 confidence  | real                        |           |          |
 speed       | real                        |           |          |
 jam_factor  | real                        |           |          |
Partition key: RANGE ("timestamp")
Number of partitions: 7 (Use \d+ to list them.)
```

### public.here_npmrds_schema table

Contains the HERE Realtime Traffic data averaged into 5 minute bins.

There will be no gaps--every 5 minute bin will have data. If there was no
realtime data for the 5 minute bin, the most relatively recent realtime data is
copied. The `staleness_minutes` column indicates how old the used realtime
data was.

While the HereRealtimeTrafficEtlService is running, the
public.here_npmrds_schema table is updated every 5 minutes, regardless of API
stale data and failures.

```psql
npmrds_production=# \d public.here_npmrds_schema
                  Table "public.here_npmrds_schema"
          Column          |   Type   | Collation | Nullable | Default
--------------------------+----------+-----------+----------+---------
 tmc                      | text     |           | not null |
 date                     | date     |           | not null |
 epoch                    | smallint |           | not null |
 travel_time_all_vehicles | real     |           | not null |
 staleness_minutes        | integer  |           | not null |
Partition key: RANGE (date)
Number of partitions: 4 (Use \d+ to list them.)
```

### public.here_realtime_traffic_current view

Always returns ONLY the most recent HERE Realtime Traffic data.
Query performance is heavily optimized.

```psql
npmrds_production=# \d public.here_realtime_traffic_current
                View "public.here_realtime_traffic_current"
   Column    |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 tmc         | text                        |           |          |
 timestamp   | timestamp without time zone |           |          |
 travel_time | real                        |           |          |
 confidence  | real                        |           |          |
 speed       | real                        |           |          |
 jam_factor  | real                        |           |          |
```

### public.here_npmrds_schema_current view

Always returns ONLY the most recent HERE Realtime Traffic 5-minute bin averaged data.
Query performance is heavily optimized.

```psql
npmrds_production=# \d public.here_npmrds_schema_current
               View "public.here_npmrds_schema_current"
          Column          |   Type   | Collation | Nullable | Default
--------------------------+----------+-----------+----------+---------
 tmc                      | text     |           |          |
 date                     | date     |           |          |
 epoch                    | smallint |           |          |
 travel_time_all_vehicles | real     |           |          |
 staleness_minutes        | integer  |           |          |
```
