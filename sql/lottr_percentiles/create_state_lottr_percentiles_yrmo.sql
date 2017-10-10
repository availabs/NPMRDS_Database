BEGIN;

--EXPLAIN ANALYZE 
CREATE TABLE "__STATE__".lottr_percentiles_y__YEAR__m__MONTH__ AS
  SELECT '__STATE__'::VARCHAR(2) AS state,
         tmc::VARCHAR(9),
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         JSONB_OBJECT_AGG (
           time_period,
           percentiles
         ) AS data
    FROM (
      SELECT tmc,
             CASE WHEN (EXTRACT(DOW from date) BETWEEN 1 AND 5) THEN
                 CASE WHEN (fifteen_min_bin BETWEEN 24 AND 39) THEN 'AM_PEAK'
                      WHEN (fifteen_min_bin BETWEEN 40 AND 63) THEN 'MIDDAY'
                      ELSE 'PM_PEAK'
                 END
                 ELSE 'WEEKEND'
               END AS time_period,
             PERCENTILE_DISC(array[0.50, 0.80])
               WITHIN GROUP (ORDER BY avg_travel_time) AS percentiles
    FROM (
      SELECT tmc,
             date,
             (epoch / 3) AS fifteen_min_bin,
             ROUND(AVG(travel_time_all_vehicles)) AS avg_travel_time
        FROM "__STATE__".npmrds_y__YEAR__m__MONTH__
        WHERE (epoch BETWEEN 72 AND 239) -- between is inclusive
        GROUP BY tmc, state, date, fifteen_min_bin
    ) AS averages
    GROUP BY tmc, time_period
  ) AS percentiles
  GROUP BY tmc;

ALTER TABLE "__STATE__".lottr_percentiles_y__YEAR__m__MONTH__
  ADD CONSTRAINT state_check 
    CHECK (state = '__STATE__'),
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  ALTER COLUMN data SET STATISTICS 0,
  INHERIT "__STATE__".lottr_percentiles,
  SET (fillfactor = 100);


CREATE UNIQUE INDEX lottr_percentiles_y__YEAR__m__MONTH___idx
  ON "__STATE__".lottr_percentiles_y__YEAR__m__MONTH__ (tmc)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".lottr_percentiles_y__YEAR__m__MONTH__
  ADD CONSTRAINT lottr_percentiles_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX lottr_percentiles_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".lottr_percentiles_y__YEAR__m__MONTH__
  USING lottr_percentiles_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".lottr_percentiles_y__YEAR__m__MONTH__;
