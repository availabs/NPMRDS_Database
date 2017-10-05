BEGIN;

CREATE TABLE "__STATE__".occupancy_factor (
  CONSTRAINT pkey PRIMARY KEY(geography_level, geography_level_name)
)
INHERITS (public.occupancy_factor)
WITH (fillfactor = 100);

ALTER TABLE "__STATE__".occupancy_factor
  ALTER COLUMN state SET DEFAULT '__STATE__'::VARCHAR(2),
  ALTER COLUMN occupancy_factor SET DEFAULT 1.5,
  ADD CONSTRAINT occupancy_factor_state_check CHECK(state = '__STATE__');

INSERT INTO "__STATE__".occupancy_factor (geography_level, geography_level_name)
  SELECT
      'COUNTY',
       county AS geography_level_name
    FROM (
      SELECT DISTINCT county
        FROM inrix_shapefile
        WHERE state = (
          SELECT state
            FROM state_abbreviations
            WHERE abbreviation = '__STATE__'
        )
    ) AS t ;

COMMIT;
