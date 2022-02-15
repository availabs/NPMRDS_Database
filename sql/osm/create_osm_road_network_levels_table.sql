/*
  // From SharedStreets
  public enum ROAD_CLASS {
      ClassMotorway(0),
      ClassTrunk(1),
      ClassPrimary(2),
      ClassSecondary(3),
      ClassTertiary(4),
      ClassResidential(5),
      ClassUnclassified(6),
      ClassService(7),
      ClassOther(8);
  }
*/

BEGIN;

CREATE SCHEMA IF NOT EXISTS osm;

CREATE TABLE IF NOT EXISTS osm.osm_road_network_levels (
  network_level   SMALLINT PRIMARY KEY,
  description     TEXT NOT NULL
) WITH (fillfactor=100) ;

INSERT INTO osm.osm_road_network_levels (
  network_level,
  description
) VALUES
  (0, 'motorway'),
  (1, 'trunk'),
  (2, 'primary'),
  (3, 'secondary'),
  (4, 'tertiary'),
  (5, 'residential'),
  (6, 'unclassified'),
  (7, 'service'),
  (8, 'other')
;

COMMIT ;
