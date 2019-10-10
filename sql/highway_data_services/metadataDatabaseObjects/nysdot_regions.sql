-- Source: https://www.dot.ny.gov/regional-offices

BEGIN;

CREATE TABLE highway_data_services.nysdot_region_names (
  region  SMALLINT PRIMARY KEY,
  name    VARCHAR(64) UNIQUE,
  CHECK (region BETWEEN 1 AND 11)
) WITH (fillfactor = 100);

INSERT INTO highway_data_services.nysdot_region_names (region, name)
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

COMMENT ON TABLE highway_data_services.nysdot_region_names IS 'NYS DOT Regions.';

COMMENT ON COLUMN highway_data_services.nysdot_region_names.region IS
'The Region Number, a number 1-11 representing a NYSDOT Region.';

COMMENT ON COLUMN highway_data_services.nysdot_region_names.name IS
'Name of the NYSDOT Region.';

COMMIT;
