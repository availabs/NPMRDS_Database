BEGIN;

DROP FUNCTION IF EXISTS lottr_percentiles_rankings_for_geography_fn (
    states VARCHAR(2)[],
    geo_level_type geography_level_type,
    geo_name VARCHAR,
    sortCol text,
    dYear INT,
    dMonth INT,
    startRank INT,
    endRank INT
  )
;

COMMIT;
