-- NOTE: script variables set in ../../make_targets/db/conflation/load-conflation-map-shapefile
--       Kind of clunky, but done to maintain single source of truth for naming conventions.

BEGIN;

CREATE SCHEMA IF NOT EXISTS :SCHEMA_NAME;

CREATE TABLE IF NOT EXISTS :FULL_TABLE_NAME (
  id                          INTEGER PRIMARY KEY,
  year                        SMALLINT NOT NULL DEFAULT :YEAR,
  dir                         SMALLINT,
  n                           SMALLINT NOT NULL,
  osm                         INTEGER,
  osm_fwd                     INTEGER,
  ris                         TEXT,
  tmc                         TEXT,
  wkb_geometry                public.geometry(LineString, 4326) NOT NULL
) WITH (fillfactor=100, autovacuum_enabled=false) ;

CREATE INDEX IF NOT EXISTS :OSM_IDX_NAME
  ON :FULL_TABLE_NAME (osm) ;

CREATE INDEX IF NOT EXISTS :RIS_IDX_NAME
  ON :FULL_TABLE_NAME (ris) ;

CREATE INDEX IF NOT EXISTS :TMC_IDX_NAME
  ON :FULL_TABLE_NAME (tmc) ;

CREATE INDEX IF NOT EXISTS :GEOM_IDX_NAME
  ON :FULL_TABLE_NAME
  USING GIST(wkb_geometry) ;

CLUSTER :FULL_TABLE_NAME USING :GEOM_IDX_NAME ;

COMMIT;

