-- https://www.dot.ny.gov/gisapps/nysdot_functional-class-maps

BEGIN;

CREATE TABLE highway_data_services.nysdot_functional_classification_code_descriptions (
  code         SMALLINT PRIMARY KEY,
  distinctor   VARCHAR,
  description  VARCHAR,
  CHECK (
    code IN (
      1, 2, 4, 6, 7, 8, 9,         -- NYS Codes Rural
      11, 12, 14, 16, 17, 18, 19   -- NYS Codes Urban
    )
  ),
  CHECK (
    distinctor IN (
      'NYS Codes Urban',
      'NYS Codes Rural'
    )
  )
) WITH (fillfactor = 100);


INSERT INTO highway_data_services.nysdot_functional_classification_code_descriptions (code, distinctor, description)
VALUES 
  (1, 'NYS Codes Rural', 'Principal Arterial - Interstate'),
  (2, 'NYS Codes Rural', 'Principal Arterial - Other Freeway/Expressway'),
  (4, 'NYS Codes Rural', 'Principal Arterial - Other'),
  (6, 'NYS Codes Rural', 'Minor Arterial'),
  (7, 'NYS Codes Rural', 'Major Collector'),
  (8, 'NYS Codes Rural', 'Minor Collector'),
  (9, 'NYS Codes Rural', 'Local'),

  (11, 'NYS Codes Urban', 'Principal Arterial - Interstate'),
  (12, 'NYS Codes Urban', 'Principal Arterial - Other Freeway/Expressway'),
  (14, 'NYS Codes Urban', 'Principal Arterial - Other'),
  (16, 'NYS Codes Urban', 'Minor Arterial'),
  (17, 'NYS Codes Urban', 'Major Collector'),
  (18, 'NYS Codes Urban', 'Minor Collector'),
  (19, 'NYS Codes Urban', 'Local')
;

COMMIT;
