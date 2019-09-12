BEGIN;

\set tbl_name 'ways_metadata_':YEAR
\set idx_name :tbl_name'_pkey'

CREATE SCHEMA IF NOT EXISTS osm;

CREATE TABLE IF NOT EXISTS osm.:tbl_name (
  id        INTEGER PRIMARY KEY,
  metadata  JSONB
);

CLUSTER osm.:tbl_name USING :idx_name;

COMMIT;
