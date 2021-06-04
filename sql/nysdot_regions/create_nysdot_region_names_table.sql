BEGIN;

CREATE SCHEMA IF NOT EXISTS ny;

DROP TABLE IF EXISTS ny.nysdot_region_names;

CREATE TABLE ny.nysdot_region_names (
  region  SMALLINT PRIMARY KEY,
  name    VARCHAR(64) UNIQUE,
  CHECK (region BETWEEN 1 AND 11)
) WITH (fillfactor=100, autovacuum_enabled=false);

INSERT INTO ny.nysdot_region_names (region, name)
VALUES
  (1,  'Capital District'),
  (2,  'Mohawk Valley'),
  (3,  'Central New York'),
  (4,  'Genesee Valley'),
  (5,  'Western New York'),
  (6,  'Southern Tier/Central New York'),
  (7,  'North Country'),
  (8,  'Hudson Valley'),
  (9,  'Southern Tier'),
  (10, 'Long Island'),
  (11, 'New York City ')
;

COMMIT;
