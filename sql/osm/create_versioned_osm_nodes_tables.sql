BEGIN;

\set tbl_name 'osm_nodes_v':OSM_VERSION
\set pkey_idx_name :tbl_name'_pkey'
\set geom_idx_name :tbl_name'_geom_idx'

CREATE SCHEMA IF NOT EXISTS osm;

DROP TABLE IF EXISTS osm.:tbl_name ;

CREATE TABLE IF NOT EXISTS osm.:tbl_name (
  id            BIGINT PRIMARY KEY,
  tags          JSONB,
  wkb_geometry  TEXT -- Changed to public.geometry(Point, 4326) after loaded.
);

CLUSTER osm.:tbl_name USING :pkey_idx_name;

COMMIT;
