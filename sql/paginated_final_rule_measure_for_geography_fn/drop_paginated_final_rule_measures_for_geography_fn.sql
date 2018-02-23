BEGIN;

DROP FUNCTION IF EXISTS paginated_final_rule_measures_for_geography_fn (
    states          VARCHAR(2)[],
    geo_level_type  geography_level_type,
    geo_name        TEXT,
    sort_col        final_rule_measure_sort_column_type,
    sort_direction  TEXT,
    d_year          INT,
    d_month         INT,
    start_rank      INT,
    end_rank        INT
  )
;

COMMIT;
