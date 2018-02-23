BEGIN;

CREATE OR REPLACE FUNCTION lottr_percentiles_rankings_for_geography_fn (
    states VARCHAR(2)[],
    geoLevelType geography_level_type,
    geoName VARCHAR,
    sortCol text,
    direction text,
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
              CASE -- Default direction is DESC
                WHEN ((%L IS NULL) OR (UPPER(%L) = ''DESC''))
                  THEN (row_number() OVER (ORDER BY %I DESC, tmc ASC) -1)
                ELSE (row_number() OVER (ORDER BY %I ASC, tmc DESC) -1)
              END AS row_number
            FROM lottr
              INNER JOIN tmcs_within_geography_fn(%L::VARCHAR(2)[], %L, %L) USING (tmc)
            WHERE (
              (year = %L)
              AND
              (month = %L)
            )
        ) AS t
        WHERE (
          ( -- startRank NULL or gte the specified
            (%L IS NULL)
            OR
            (row_number >= %L)
          )
          AND
          ( -- endRank NULL or lte the specified
            (%L IS NULL)
            OR
            (row_number <= %L)
          )
        )
      ', direction, direction, sortCol, sortCol, states, geoLevelType, geoName, dYear, dMonth, startRank, startRank, endRank, endRank);
    END
  $func$ LANGUAGE plpgsql
;

COMMIT;
