-- https://www.fhwa.dot.gov/policyinformation/tmguide/tmg_2013/traffic-monitoring-formats.cfm

BEGIN;

CREATE TABLE highway_data_services.fhwa_direction_of_travel_code_descriptions (
  code         SMALLINT PRIMARY KEY,
  description  VARCHAR(80) UNIQUE,
  CHECK (code BETWEEN 0 AND 9) 
) WITH (fillfactor=100, autovacuum_enabled=false);

INSERT INTO highway_data_services.fhwa_direction_of_travel_code_descriptions (code, description)
  VALUES
    (1,	'North'),
    (2,	'Northeast'),
    (3,	'East'),
    (4,	'Southeast'),
    (5,	'South'),
    (6,	'Southwest'),
    (7,	'West'),
    (8,	'Northwest'),
    (9,	'North-South or Northeast-Southwest combined (volume stations only)'),
    (0,	'East-West or Southeast-Northwest combined (volume stations only)')
;

COMMENT ON COLUMN highway_data_services.fhwa_direction_of_travel_code_descriptions.code IS
'The direction of travel of the main roadway.';

COMMIT;
