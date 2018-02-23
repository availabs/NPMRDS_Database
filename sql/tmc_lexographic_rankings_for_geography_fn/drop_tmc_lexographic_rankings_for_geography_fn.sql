BEGIN;

DROP FUNCTION IF EXISTS tmc_lexographic_rankings_for_geography_fn (
    states          VARCHAR(2)[],
    geo_level_type  geography_level_type,
    geo_name        TEXT,
    sort_direction  TEXT,
    start_rank      INT,
    end_rank        INT
  )
;

COMMIT;
