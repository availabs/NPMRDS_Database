BEGIN;

CREATE FUNCTION tttr_percentiles_rankings_fn (
    _t text,
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
            FROM tttr_percentiles_rankings
            WHERE (
              (year = %s)
              AND
              (month = %s)
            )
        ) AS t
        WHERE (
          (
            (%s IS NULL)
            OR
            (row_number >= %s)
          )
          AND
          (
            (%s IS NULL)
            OR
            (row_number <= %s)
          )
        )
      ', _t, dYear, dMonth, startRank, startRank, endRank, endRank);
    END
  $func$ LANGUAGE plpgsql
;

COMMIT;
