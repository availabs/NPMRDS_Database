BEGIN;

\set tbl_name 'conflation_metadata_':YEAR
\set idx_name :tbl_name'_pkey'

CREATE SCHEMA IF NOT EXISTS shst;

CREATE TABLE IF NOT EXISTS shst.:tbl_name (
  id                         INTEGER PRIMARY KEY,
  osm                        INTEGER,
  tmc                        CHARACTER VARYING(9),
  ris                        INTEGER,
  shst_geometry_id           CHARACTER VARYING,
  shst_reference_id          CHARACTER VARYING,
  shst_from_intersection_id  CHARACTER VARYING,
  shst_to_intersection_id    CHARACTER VARYING,
  shst_reversed              BOOLEAN,
  shst_total_segments        INTEGER,
  shst_segment_index         INTEGER,
  shst_start_dist            DOUBLE PRECISION,
  shst_end_dist              DOUBLE PRECISION
);

CLUSTER shst.:tbl_name USING :idx_name;

COMMIT;
