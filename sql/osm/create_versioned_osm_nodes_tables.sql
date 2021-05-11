BEGIN;

\set tbl_name 'osm_nodes_v':OSM_VERSION
\set pkey_idx_name :tbl_name'_pkey'
\set geom_idx_name :tbl_name'_geom_idx'

CREATE SCHEMA IF NOT EXISTS osm;

CREATE TABLE IF NOT EXISTS osm.:tbl_name (
  id            BIGINT PRIMARY KEY,
  tags          JSONB,
  wkb_geometry  public.geometry(Point, 4326)
) WITH (fillfactor=100, autovacuum_enabled=false) ;

CREATE INDEX :geom_idx_name
  ON osm.:tbl_name
  USING GIST (wkb_geometry) ;

CLUSTER osm.:tbl_name USING :pkey_idx_name;

COMMIT;
