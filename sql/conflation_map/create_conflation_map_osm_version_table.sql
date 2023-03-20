BEGIN;

CREATE SCHEMA IF NOT EXISTS conflation;

CREATE TABLE IF NOT EXISTS conflation.conflation_map_osm_version (
  conflation_map_version      TEXT PRIMARY KEY,
  osm_map_version             TEXT NOT NULL
) ;

COMMIT;

