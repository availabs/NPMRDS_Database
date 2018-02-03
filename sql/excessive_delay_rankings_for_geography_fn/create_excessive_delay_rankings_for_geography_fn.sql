BEGIN;

CREATE OR REPLACE FUNCTION excessive_delay_rankings_for_geography_fn (
    states VARCHAR(2)[],
    geo_level_type geography_level_type,
    geo_name VARCHAR,
    sortCol text,
    dYear INT,
    dMonth INT,
    startRank INT,
    endRank INT
  )
  RETURNS TABLE (tmc VARCHAR, row_number BIGINT)
  AS $func$
    BEGIN
      RETURN QUERY EXECUTE format('
      SELECT
          tmc,
          row_number
        FROM (
          SELECT
              tmc,
              (row_number() OVER (ORDER BY %I, tmc) -1) AS row_number
            FROM excessive_delay_rankings
              INNER JOIN tmcs_within_geography_fn(%L::VARCHAR(2)[], %L, %L) USING (tmc)
            WHERE (
              (year = %L)
              AND
              (month = %L)
            )
        ) AS t
        WHERE (
          (
            (%L IS NULL)
            OR
            (row_number >= %L)
          )
          AND
          (
            (%s IS NULL)
            OR
            (row_number <= %s)
          )
        )
      ', sortCol, states, geo_level_type, geo_name, dYear, dMonth, startRank, startRank, endRank, endRank);
    END
  $func$ LANGUAGE plpgsql
;

COMMIT;
