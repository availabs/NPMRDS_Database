BEGIN;

CREATE OR REPLACE FUNCTION tmcs_in_final_rule_measure_rank_range_for_geography_fn (
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
  RETURNS JSONB
  AS $body$
      SELECT
          JSONB_AGG((rankings).tmc ORDER BY (rankings).rank) AS tmcs
        FROM (
          SELECT 
              CASE
                WHEN (
                  (sort_col IS NULL)
                  OR
                  (LOWER(sort_col::TEXT) = 'tmc')
                ) THEN tmc_lexographic_rankings_for_geography_fn (
                    states,
                    geo_level_type,
                    geo_name,
                    sort_direction,
                    start_rank,
                    end_rank
                ) ELSE final_rule_measure_rankings_for_geography_fn (
                    states,
                    geo_level_type,
                    geo_name,
                    sort_col,
                    sort_direction,
                    d_year,
                    d_month,
                    start_rank,
                    end_rank
                )
            END::tmc_ranking_type AS rankings
        ) AS sub_rankings
  $body$ LANGUAGE SQL
;

COMMIT;
