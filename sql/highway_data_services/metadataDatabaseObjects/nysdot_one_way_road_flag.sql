-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_CC%20Formats.pdf

BEGIN;

CREATE TABLE highway_data_services.nysdot_one_way_road_flag_descriptions (
  flag_value    CHAR(1) UNIQUE,
  description   VARCHAR(16) UNIQUE,
  CHECK ((flag_value = 'Y') OR (flag_value IS NULL)) 
) WITH (fillfactor = 100);

COMMENT ON TABLE highway_data_services.nysdot_one_way_road_flag_descriptions IS
'Indicates if the segment is a one‐way road. ‘Y’ for one‐way or null for bi‐directional.';

INSERT INTO highway_data_services.nysdot_one_way_road_flag_descriptions (flag_value, description)
  VALUES
    ('Y', 'one-way'),
    (NULL, 'bi-directional')
  ;

COMMIT;
