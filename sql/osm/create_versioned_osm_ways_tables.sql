BEGIN;

\set tbl_name 'osm_ways_v':OSM_VERSION
\set pkey_idx_name :tbl_name'_pkey'
\set node_idx_name :tbl_name'_node_idx'

CREATE SCHEMA IF NOT EXISTS osm;

DROP TABLE IF EXISTS osm.:tbl_name ;

CREATE TABLE IF NOT EXISTS osm.:tbl_name (
  id            BIGINT PRIMARY KEY,
  tags          TEXT,
  node_ids      BIGINT[] NOT NULL
);

CREATE INDEX :node_idx_name
  ON osm.:tbl_name
  USING GIN (node_ids) ;

CLUSTER osm.:tbl_name USING :pkey_idx_name;

COMMIT;
