-- This table essentially acts as a Materialized View.
--   However, Tables allow ALTER statements without first dropping dependent DB objects.
--   Redefining a Materialized View definition requires DROPPING dependent DB objects.
--   Also, wrapping the TRUNCATE and INSERT in a transaction allows reads to continue.
--   Refreshing a materialized view locks it.

BEGIN;

\set tbl_name 'conflation_metadata_':YEAR
\set idx_name :tbl_name'_pkey'

CREATE SCHEMA IF NOT EXISTS conflation;

CREATE TABLE IF NOT EXISTS conflation.:tbl_name (
  id                         INTEGER PRIMARY KEY,
  avg_daily_gtfs_trips_amp   REAL,
  avg_daily_gtfs_trips_midd  REAL,
  avg_daily_gtfs_trips_pmp   REAL,
  avg_daily_gtfs_trips_we    REAL,
  avg_daily_gtfs_trips_ovn   REAL
) WITH (fillfactor=100);

TRUNCATE conflation.:tbl_name;

INSERT INTO conflation.:tbl_name (
    id,
    avg_daily_gtfs_trips_amp,
    avg_daily_gtfs_trips_midd,
    avg_daily_gtfs_trips_pmp,
    avg_daily_gtfs_trips_we,
    avg_daily_gtfs_trips_ovn
  )
  SELECT
      id,
      amp  AS avg_daily_gtfs_trips_amp,
      midd AS avg_daily_gtfs_trips_midd,
      pmp  AS avg_daily_gtfs_trips_pmp,
      we   AS avg_daily_gtfs_trips_we,
      ovn  AS avg_daily_gtfs_trips_ovn
    FROM conflation.avg_daily_gtfs_trips_:YEAR
;

CLUSTER conflation.:tbl_name USING :idx_name;

COMMIT;

ANALYZE conflation.:tbl_name;
