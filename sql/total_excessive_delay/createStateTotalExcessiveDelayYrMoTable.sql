------ https://npmrds.ritis.org/analytics/help/#npmrds
------ Can I download data averaged every X minutes?
----
----  The NPMRDS data is stored in 5-minute bins, but the Massive Data Downloader
----  tool lets you aggregate the data in 10-, 15-, 30-, or 60-minute bins to help
----  reduce the size of your results document.  When we aggregate the data:
----  
----      The timestamp represents the beginning of the chosen interval Speed are
----      calculated using the harmonic mean of the 5-minute values that fall within the
----      granularity bin you choose....

BEGIN;

CREATE TABLE IF NOT EXISTS "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__ AS
  SELECT
      '__STATE__'::VARCHAR(2) AS state,
      travel_times.tmc::VARCHAR AS tmc,
      __YEAR__::SMALLINT AS year,
      __MONTH__::SMALLINT AS month,
      SUM(
        ROUND(((LEAST(harmonic_mean, 900) - excessive_delay_threshold_time_s) / 3600)::NUMERIC, 3) 
        * (tmc_info.aadt * (hourly_volumes.pct_daily_vol / 100.0) / 4 /*15min*/ / 2 /*aadt is bidirectional*/)
      )::DOUBLE PRECISION AS total_excessive_delay
    FROM (
        SELECT
            tmc,
            date,
            FLOOR(epoch / 3)::SMALLINT AS quarter_hour_bin,
            (COUNT(1) / SUM(1/NULLIF(travel_time_all_vehicles, 0))) AS harmonic_mean
          FROM "__STATE__".npmrds
          WHERE ((date >= '__START_DATE__'::DATE) AND (date < '__END_DATE__'::DATE))
          GROUP BY
            tmc,
            date,
            quarter_hour_bin
      ) travel_times
        LEFT OUTER JOIN (
          SELECT
              tmc,
              aadt,
              occupancy_factor,
              CASE WHEN NULLIF(avg_speedlimit, 0) IS NOT NULL
                THEN (
                  -- miles to nearest thousandth per measure rule
                  -- MAX(60% of speedlimit or 20 mph)
                  -- nearest whole second
                  ROUND(ROUND(miles::NUMERIC, 3) / GREATEST(avg_speedlimit * 0.6, 20) * 3600)::SMALLINT
                ) ELSE NULL
              END AS excessive_delay_threshold_time_s,
              congestion_level,
              directionality,
              CASE WHEN (f_system < 3)
                THEN 'FREEWAY'::traffic_dist_functional_class_type
                ELSE 'NONFREEWAY'::traffic_dist_functional_class_type
              END AS functional_class
            FROM tmc_attributes
        ) AS tmc_info USING (tmc)
        LEFT OUTER JOIN (
          SELECT 
              day_type,
              congestion_level,
              directionality,
              functional_class,
              FLOOR(epoch / 12)::SMALLINT AS hour,
              SUM(percent_daily_volume) pct_daily_vol
            FROM traffic_distributions
            GROUP BY
              day_type,
              congestion_level,
              directionality,
              functional_class,
              FLOOR(epoch / 12)
        ) AS hourly_volumes ON (
            (FLOOR(travel_times.quarter_hour_bin / 4)::SMALLINT = hourly_volumes.hour::SMALLINT)
            AND (
              (
                CASE WHEN (EXTRACT(DOW FROM travel_times.date) BETWEEN 1 AND 5)
                  THEN 'WEEKDAY'::traffic_dist_day_type
                  ELSE 'WEEKEND'::traffic_dist_day_type
                END
              ) = hourly_volumes.day_type
            )
            AND (tmc_info.functional_class = hourly_volumes.functional_class)
            AND (
              (EXTRACT(DOW FROM travel_times.date) NOT BETWEEN 1 AND 5)
              OR (
                (tmc_info.congestion_level = hourly_volumes.congestion_level)
                AND
                (tmc_info.directionality = hourly_volumes.directionality)
              )
            )
          )
    WHERE ((harmonic_mean - excessive_delay_threshold_time_s) > 0)
    GROUP BY travel_times.tmc
;


ALTER TABLE "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
  ADD CONSTRAINT state_check 
    CHECK (state = '__STATE__'),
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  INHERIT "__STATE__".total_excessive_delay,
  SET (fillfactor = 100, autovacuum_enabled=false);


CREATE UNIQUE INDEX total_excessive_delay_y__YEAR__m__MONTH___idx
  ON "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__ (tmc)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
  ADD CONSTRAINT total_excessive_delay_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX total_excessive_delay_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
  USING total_excessive_delay_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__;
