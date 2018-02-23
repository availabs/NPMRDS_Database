BEGIN;

CREATE OR REPLACE FUNCTION final_rule_measure_rankings_for_geography_fn (
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
  RETURNS SETOF tmc_ranking_type
  AS $func$
    BEGIN
      RETURN QUERY EXECUTE format('
      SELECT
          tmc::VARCHAR(9),
          row_number::INTEGER
        FROM (
          SELECT
              tmc,
              CASE -- Default sort_direction is DESC
                WHEN (%L = ''DESC'')
                  THEN (row_number() OVER (ORDER BY %I DESC NULLS LAST, tmc COLLATE "C" ASC) -1)
                ELSE (row_number() OVER (ORDER BY %I ASC NULLS FIRST, tmc COLLATE "C" DESC) -1)
              END AS row_number
            FROM %I
              INNER JOIN tmcs_within_geography_fn(%L::VARCHAR(2)[], %L, %L) USING (tmc)
            WHERE (
              (year = %L)
              AND
              (month = %L)
            )
        ) AS t
        WHERE (
          (row_number >= %L)
          AND
          (row_number <= %L::FLOAT8)
        )
        ', 
        UPPER(COALESCE(sort_direction, 'DESC')),
        LOWER(sort_col::TEXT),
        LOWER(sort_col::TEXT),
        -- All measure columns are prefixed by the measure acronym.
        -- We extract that prefix and use it as the table name.
        LOWER(
          UPPER(
            SPLIT_PART(sort_col::TEXT, '_', 1)
          )::final_rule_measure_type::TEXT
        ),
        states,
        geo_level_type,
        geo_name,
        d_year,
        d_month,
        COALESCE(start_rank, 0),
        COALESCE(end_rank::FLOAT8, 'INFINITY'::FLOAT8)
      );
    END
  $func$ LANGUAGE plpgsql
;

COMMIT;
