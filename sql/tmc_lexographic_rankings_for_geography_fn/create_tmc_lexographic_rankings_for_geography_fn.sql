BEGIN;

CREATE OR REPLACE FUNCTION tmc_lexographic_rankings_for_geography_fn (
    states          VARCHAR(2)[],
    geo_level_type  geography_level_type,
    geo_name        TEXT,
    sort_direction  TEXT,
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
                WHEN (%L = ''ASC'')
                  THEN (row_number() OVER (ORDER BY tmc COLLATE "C" ASC) -1)
                ELSE (row_number() OVER (ORDER BY tmc COLLATE "C" DESC) -1)
              END AS row_number
            FROM tmcs_within_geography_fn(%L::VARCHAR(2)[], %L, %L)
        ) AS t
        WHERE (
          (row_number >= %L)
          AND
          (row_number::FLOAT8 <= %L::FLOAT8)
        )
        ',
        UPPER(COALESCE(sort_direction, 'ASC')),
        states,
        geo_level_type,
        geo_name,
        COALESCE(start_rank, 0),
        COALESCE(end_rank::FLOAT8, 'INFINITY'::FLOAT8)
      );
    END
  $func$ LANGUAGE plpgsql
;

COMMIT;
