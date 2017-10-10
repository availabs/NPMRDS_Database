BEGIN;

CREATE TABLE "__STATE__".tttr_percentiles_y__YEAR__m__MONTH__ AS
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
           CASE WHEN ((fifteen_min_bin < 24) OR (fifteen_min_bin > 63)) THEN 'OVERNIGHT'
                ELSE CASE WHEN (EXTRACT(DOW from date) BETWEEN 1 AND 5) THEN
                          CASE WHEN (fifteen_min_bin BETWEEN 24 AND 39) THEN 'AM_PEAK'
                               WHEN (fifteen_min_bin BETWEEN 40 AND 63) THEN 'MIDDAY'
                               ELSE 'PM_PEAK'
                          END
                          ELSE 'WEEKEND'
                     END
           END AS time_period,
           PERCENTILE_DISC(array[0.50, 0.95])
             WITHIN GROUP (ORDER BY avg_travel_time) AS percentiles
  FROM (
    SELECT tmc,
           (epoch / 3) AS fifteen_min_bin,
           date,
           ROUND(AVG(COALESCE(travel_time_freight_trucks, travel_time_all_vehicles))) AS avg_travel_time
      FROM "__STATE__".npmrds_y__YEAR__m__MONTH__
      GROUP BY tmc, state, date, fifteen_min_bin
  ) AS averages
  GROUP BY tmc, time_period
) AS percentiles
GROUP BY tmc;

ALTER TABLE "__STATE__".tttr_percentiles_y__YEAR__m__MONTH__
  ADD CONSTRAINT state_check 
    CHECK (state = '__STATE__'),
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  ALTER COLUMN data SET STATISTICS 0,
  INHERIT "__STATE__".tttr_percentiles,
  SET (fillfactor = 100);


CREATE UNIQUE INDEX tttr_percentiles_y__YEAR__m__MONTH___idx
  ON "__STATE__".tttr_percentiles_y__YEAR__m__MONTH__ (tmc)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".tttr_percentiles_y__YEAR__m__MONTH__
  ADD CONSTRAINT tttr_percentiles_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX tttr_percentiles_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".tttr_percentiles_y__YEAR__m__MONTH__
  USING tttr_percentiles_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".tttr_percentiles_y__YEAR__m__MONTH__;
