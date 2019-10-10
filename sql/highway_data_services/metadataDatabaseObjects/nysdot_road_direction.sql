-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_CC%20Formats.pdf

BEGIN;

CREATE TABLE highway_data_services.nysdot_road_direction_code_descriptions (
  code         SMALLINT PRIMARY KEY,
  description  VARCHAR UNIQUE,
  CHECK ((code = 99) OR (code = -99))
) WITH (fillfactor = 100);

COMMENT ON TABLE highway_data_services.nysdot_road_direction_code_descriptions IS
'The direction of the data for each record.';

INSERT INTO highway_data_services.nysdot_road_direction_code_descriptions (code, description)
VALUES 
  ( 99,  '99 represents data traveling from the Begin Desc to the End Desc, or primary direction'),
  (-99, '-99 represents data traveling from the End Desc to the Begin Desc, or non‐primary direction.')
;

COMMIT;
