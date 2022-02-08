BEGIN;

\set tbl_name 'osm_relations_v':OSM_VERSION
\set pkey_idx_name :tbl_name'_pkey'

CREATE SCHEMA IF NOT EXISTS osm;

CREATE TABLE IF NOT EXISTS osm.:tbl_name (
  id            BIGINT PRIMARY KEY,
  tags          JSONB,
  members       JSONB
) WITH (fillfactor=100, autovacuum_enabled=false) ;

CLUSTER osm.:tbl_name USING :pkey_idx_name;

COMMIT;
