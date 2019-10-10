-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_SC%20Formats.pdf

BEGIN;

CREATE TABLE highway_data_services.nysdot_vehicle_axle_code_descriptions (
  code         SMALLINT PRIMARY KEY,
  description  VARCHAR UNIQUE,
  CHECK ((code = 1) OR (code = 2))
) WITH (fillfactor=100, autovacuum_enabled=false);

INSERT INTO highway_data_services.nysdot_vehicle_axle_code_descriptions (code, description)
VALUES 
  (1, 'Vehicle Count'),
  (2, 'Axles/2 Count')
;

COMMENT ON COLUMN highway_data_services.nysdot_vehicle_axle_code_descriptions.code IS
'Vehicle/Axle code in Volume files: 1=Vehicle count 2=Axles/2 count.';

COMMENT ON TABLE highway_data_services.nysdot_vehicle_axle_code_descriptions IS
'Descriptions for the NYSDOT vehicle_axle_codes.';

COMMIT;
