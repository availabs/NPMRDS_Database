-- SharedStreets road criteria used for osm_roads_v filter:
--   https://github.com/sharedstreets/sharedstreets-builder/blob/master/src/main/java/io/sharedstreets/tools/builder/osm/model/Way.java#L61-L94

BEGIN;

\set tbl_name 'osm_ways_v':OSM_VERSION
\set view_name 'osm_roads_v':OSM_VERSION
\set pkey_idx_name :tbl_name'_pkey'
\set node_idx_name :tbl_name'_node_idx'
\set highway_tag_idx :tbl_name'_hwy_idx'
\set service_tag_idx :tbl_name'_svc_idx'
\set geom_idx_name :tbl_name'_geom_idx'

CREATE SCHEMA IF NOT EXISTS osm;

CREATE TABLE IF NOT EXISTS osm.:tbl_name (
  id            BIGINT PRIMARY KEY,
  tags          JSONB,
  node_ids      BIGINT[] NOT NULL,
  wkb_geometry  geometry(LineString, 4326)
) WITH (fillfactor=100, autovacuum_enabled=false) ;

CREATE INDEX :node_idx_name
  ON osm.:tbl_name
  USING GIN (node_ids) ;

CREATE INDEX :highway_tag_idx
  ON osm.:tbl_name ((tags->>'highway'));

CREATE INDEX :service_tag_idx
  ON osm.:tbl_name ((tags->>'service'));

CREATE INDEX :geom_idx_name
  ON osm.:tbl_name
  USING GIST (wkb_geometry) ;

CREATE VIEW osm.:view_name
  AS
    SELECT
        id,
        tags,
        node_ids,
        tags->>'highway' AS highway,
        ( ST_Length(GEOGRAPHY(wkb_geometry)) / 1000.0 ) AS length_km,
        wkb_geometry
      FROM osm.:tbl_name
      WHERE (
        ( tags->>'highway' IN (
            'motorway',
            'trunk',
            'primary',
            'secondary',
            'tertiary',
            'unclassified',
            'residential',
            'living_street',
            'service'
          )
        )
        OR
        (
          ( tags->>'highway' = 'service' )
          AND
          ( tags->>'service' NOT IN (
              'parking',
              'driveway',
              'drive-through'
            )
          )
        )
      )
;

CLUSTER osm.:tbl_name USING :pkey_idx_name;

COMMIT;
