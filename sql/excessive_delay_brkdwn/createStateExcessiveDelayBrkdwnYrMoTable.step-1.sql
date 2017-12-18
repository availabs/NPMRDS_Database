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

CREATE TABLE IF NOT EXISTS "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__ (
  LIKE "__STATE__".excessive_delay_brkdwn EXCLUDING ALL
) WITH (fillfactor = 100, autovacuum_enabled = false);


INSERT INTO "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__ (state, year, month, tmc, excessive_delay_brkdwn)
  WITH cte_tmc_info AS (
    SELECT
        tmc,
        aadt,
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
  ), cte_hourly_volumes AS (
    SELECT 
        day_type,
        congestion_level,
        directionality,
        functional_class,
        FLOOR(epoch / 12)::SMALLINT AS hour,
        SUM(percent_daily_volume) pct_daily_vol
      FROM traffic_distributions
      WHERE day_type = 'WEEKDAY'
      GROUP BY
        day_type,
        congestion_level,
        directionality,
        functional_class,
        FLOOR(epoch / 12)
  ), cte_delays_by_quarter_hour AS (
    SELECT
        travel_times.tmc::VARCHAR AS tmc,
        quarter_hour_bin::SMALLINT,
        CASE 
          WHEN ( -- LEAST ignores NULLs.
            (excessive_delay_threshold_time_s IS NOT NULL)
            AND
            (harmonic_mean_travel_time IS NOT NULL)
          )
          THEN 
            ROUND(
              (
                GREATEST(
                  LEAST(harmonic_mean_travel_time - excessive_delay_threshold_time_s, 900),
                  0
                ) / 3600
              )::NUMERIC,
              3
            )
          ELSE NULL
        END AS excessive_delay_hrs
      FROM (
          SELECT
              tmc,
              date,
              FLOOR(epoch / 3)::SMALLINT AS quarter_hour_bin,
              (COUNT(1) / SUM(1/NULLIF(travel_time_all_vehicles, 0))) AS harmonic_mean_travel_time
            FROM "__STATE__".npmrds
            WHERE ((date >= '__START_DATE__'::DATE) AND (date < '__END_DATE__'::DATE)) 
              AND (
                (epoch BETWEEN (6*12) AND (10*12 - 1))
                OR
                (epoch BETWEEN (15*12) AND (20*12 - 1))
              )
              AND (EXTRACT(DOW FROM date) BETWEEN 1 AND 5)
              AND (
                ('__START_TMC__' = '__START' || '_TMC__')
                OR
                (
                  -- NOTE: '__END' > '999', so no need to replace on last partition
                  (tmc >= '__START_TMC__') AND (tmc < '__END_TMC__') 
                )
              )
            GROUP BY
              tmc,
              date,
              quarter_hour_bin
        ) travel_times
          LEFT OUTER JOIN cte_tmc_info USING (tmc)
  ), cte_hourly_summary_stats AS (
      SELECT
          tmc,
          FLOOR(quarter_hour_bin / 4) AS hour,
          JSONB_BUILD_OBJECT(
            'total_xdelay_hrs',
            ROUND(
              SUM(
                excessive_delay_hrs
                * (
                  cte_tmc_info.aadt
                  * (cte_hourly_volumes.pct_daily_vol / 100.0)
                  / 4 /*15min*/
                  / 2 /*aadt is bidir*/
                )
              )::NUMERIC,
              3
            ),

            'summary_stats',
            JSONB_BUILD_OBJECT(
              'sum',
              ROUND(
                SUM(excessive_delay_hrs)::NUMERIC,
                3
              ),

              'quartiles',
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (ORDER BY excessive_delay_hrs)::REAL[5],

              'mean',
              AVG(excessive_delay_hrs)::REAL,

              'stddev',
              STDDEV_POP(excessive_delay_hrs)::REAL,

              '15_min_bin_ct',
              COUNT(1)::SMALLINT
            ),

            'by_quarter_hour',
            JSONB_OBJECT_AGG(
              quarter_hour_bin,
              cte_quarter_hour_summary_stats.brkdwn
            )
          ) AS brkdwn
      FROM cte_delays_by_quarter_hour
        LEFT OUTER JOIN (
            SELECT
                tmc,
                quarter_hour_bin,
                JSONB_BUILD_OBJECT(
                  'total_xdelay_hrs',
                  ROUND(
                    SUM(
                      excessive_delay_hrs
                      * (
                        cte_tmc_info.aadt
                        * (cte_hourly_volumes.pct_daily_vol / 100.0)
                        / 4 /*15min*/
                        / 2 /*aadt is bidir*/
                      )
                    )::NUMERIC,
                    3
                  ),

                  'summary_stats',
                  JSONB_BUILD_OBJECT(
                    'sum',
                    ROUND(
                      SUM(excessive_delay_hrs)::NUMERIC,
                      3
                    ),

                    'quartiles',
                    PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                      WITHIN GROUP (ORDER BY excessive_delay_hrs)::REAL[5],

                    'mean',
                    AVG(excessive_delay_hrs)::REAL,

                    'stddev',
                    STDDEV_POP(excessive_delay_hrs)::REAL,

                    '15_min_bin_ct',
                    COUNT(1)::SMALLINT
                  )
                ) AS brkdwn
            FROM cte_delays_by_quarter_hour
              LEFT OUTER JOIN cte_tmc_info USING (tmc)
              LEFT OUTER JOIN cte_hourly_volumes ON (
                (
                  FLOOR(cte_delays_by_quarter_hour.quarter_hour_bin / 4)::SMALLINT
                    = cte_hourly_volumes.hour::SMALLINT
                )
                AND (cte_tmc_info.functional_class = cte_hourly_volumes.functional_class)
                AND (cte_tmc_info.congestion_level = cte_hourly_volumes.congestion_level)
                AND (cte_tmc_info.directionality = cte_hourly_volumes.directionality)
              )
            GROUP BY cte_delays_by_quarter_hour.tmc, quarter_hour_bin, aadt, pct_daily_vol
          ) AS cte_quarter_hour_summary_stats USING (tmc, quarter_hour_bin)
        LEFT OUTER JOIN cte_tmc_info USING (tmc)
        LEFT OUTER JOIN cte_hourly_volumes ON (
          (
            FLOOR(cte_delays_by_quarter_hour.quarter_hour_bin / 4)::SMALLINT
              = cte_hourly_volumes.hour::SMALLINT
          )
          AND (cte_tmc_info.functional_class = cte_hourly_volumes.functional_class)
          AND (cte_tmc_info.congestion_level = cte_hourly_volumes.congestion_level)
          AND (cte_tmc_info.directionality = cte_hourly_volumes.directionality)
        )
      GROUP BY cte_delays_by_quarter_hour.tmc, FLOOR(quarter_hour_bin / 4), aadt, pct_daily_vol
  )
  SELECT
      '__STATE__'::VARCHAR(2) AS state,
      __YEAR__::SMALLINT AS year,
      __MONTH__::SMALLINT AS month,
      tmc::VARCHAR(9),
      JSONB_OBJECT_AGG(
        phed_peak_period,
        brkdwn
      ) AS excessive_delay_brkdwn
    FROM (
      SELECT
          cte_delays_by_quarter_hour.tmc,
          'PHED_AM_PEAK'::phed_peak_period_type AS phed_peak_period,
          JSONB_BUILD_OBJECT(
            'total_xdelay_hrs',
            ROUND(
              SUM(
                excessive_delay_hrs
                * (
                  cte_tmc_info.aadt
                  * (cte_hourly_volumes.pct_daily_vol / 100.0)
                  / 4 /*15min*/
                  / 2 /*aadt is bidir*/
                )
              )::NUMERIC,
              3
            ),

            'summary_stats',
            JSONB_BUILD_OBJECT(
              'sum',
              ROUND(
                SUM(excessive_delay_hrs)::NUMERIC,
                3
              ),

              'quartiles',
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (ORDER BY excessive_delay_hrs)::REAL[5],

              'mean',
              AVG(excessive_delay_hrs)::REAL,

              'stddev',
              STDDEV_POP(excessive_delay_hrs)::REAL,

              '15_min_bin_ct',
              COUNT(1)::SMALLINT
            ),

            'by_hour',
            JSONB_OBJECT_AGG(
              cte_hourly_summary_stats.hour,
              cte_hourly_summary_stats.brkdwn
            )
          ) AS brkdwn

        FROM cte_delays_by_quarter_hour
          LEFT OUTER JOIN cte_hourly_summary_stats
            ON (
              (cte_delays_by_quarter_hour.tmc = cte_hourly_summary_stats.tmc)
              AND
              (FLOOR(cte_delays_by_quarter_hour.quarter_hour_bin / 4) = cte_hourly_summary_stats.hour)
            )
          LEFT OUTER JOIN cte_tmc_info
            ON (cte_delays_by_quarter_hour.tmc = cte_tmc_info.tmc)
          LEFT OUTER JOIN cte_hourly_volumes ON (
            (
              FLOOR(cte_delays_by_quarter_hour.quarter_hour_bin / 4)::SMALLINT
                = cte_hourly_volumes.hour::SMALLINT
            )
            AND (cte_tmc_info.functional_class = cte_hourly_volumes.functional_class)
            AND (cte_tmc_info.congestion_level = cte_hourly_volumes.congestion_level)
            AND (cte_tmc_info.directionality = cte_hourly_volumes.directionality)
          )
        WHERE (quarter_hour_bin BETWEEN (6*4) AND (10*4 -1))
        GROUP BY cte_delays_by_quarter_hour.tmc, aadt
      UNION
      SELECT
          cte_delays_by_quarter_hour.tmc,
          'PHED_PM_PEAK_1'::phed_peak_period_type AS phed_peak_period,
          JSONB_BUILD_OBJECT(
            'total_xdelay_hrs',
            ROUND(
              SUM(
                excessive_delay_hrs
                * (
                  cte_tmc_info.aadt
                  * (cte_hourly_volumes.pct_daily_vol / 100.0)
                  / 4 /*15min*/
                  / 2 /*aadt is bidir*/
                )
              )::NUMERIC,
              3
            ),

            'summary_stats',
            JSONB_BUILD_OBJECT(
              'sum',
              ROUND(
                SUM(excessive_delay_hrs)::NUMERIC,
                3
              ),

              'quartiles',
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (ORDER BY excessive_delay_hrs)::REAL[5],

              'mean',
              AVG(excessive_delay_hrs)::REAL,

              'stddev',
              STDDEV_POP(excessive_delay_hrs)::REAL,

              '15_min_bin_ct',
              COUNT(1)::SMALLINT
            ),

            'by_hour',
            JSONB_OBJECT_AGG(
              cte_hourly_summary_stats.hour,
              cte_hourly_summary_stats.brkdwn
            )
          ) AS brkdwn

        FROM cte_delays_by_quarter_hour
          LEFT OUTER JOIN cte_hourly_summary_stats
            ON (
              (cte_delays_by_quarter_hour.tmc = cte_hourly_summary_stats.tmc)
              AND
              (FLOOR(cte_delays_by_quarter_hour.quarter_hour_bin / 4) = cte_hourly_summary_stats.hour)
            )
          LEFT OUTER JOIN cte_tmc_info
            ON (cte_delays_by_quarter_hour.tmc = cte_tmc_info.tmc)
          LEFT OUTER JOIN cte_hourly_volumes ON (
            (
              FLOOR(cte_delays_by_quarter_hour.quarter_hour_bin / 4)::SMALLINT
                = cte_hourly_volumes.hour::SMALLINT
            )
            AND (cte_tmc_info.functional_class = cte_hourly_volumes.functional_class)
            AND (cte_tmc_info.congestion_level = cte_hourly_volumes.congestion_level)
            AND (cte_tmc_info.directionality = cte_hourly_volumes.directionality)
          )
        WHERE (quarter_hour_bin BETWEEN (15*4) AND (19*4 -1))
        GROUP BY cte_delays_by_quarter_hour.tmc, FLOOR(quarter_hour_bin / 4), aadt
      UNION
      SELECT
          cte_delays_by_quarter_hour.tmc,
          'PHED_PM_PEAK_2'::phed_peak_period_type AS phed_peak_period,
          JSONB_BUILD_OBJECT(
            'total_xdelay_hrs',
            ROUND(
              SUM(
                excessive_delay_hrs
                * (
                  cte_tmc_info.aadt
                  * (cte_hourly_volumes.pct_daily_vol / 100.0)
                  / 4 /*15min*/
                  / 2 /*aadt is bidir*/
                )
              )::NUMERIC,
              3
            ),

            'summary_stats',
            JSONB_BUILD_OBJECT(
              'sum',
              ROUND(
                SUM(excessive_delay_hrs)::NUMERIC,
                3
              ),

              'quartiles',
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (ORDER BY excessive_delay_hrs)::REAL[5],

              'mean',
              AVG(excessive_delay_hrs)::REAL,

              'stddev',
              STDDEV_POP(excessive_delay_hrs)::REAL,

              '15_min_bin_ct',
              COUNT(1)::SMALLINT
            ),

            'by_hour',
            JSONB_OBJECT_AGG(
              cte_hourly_summary_stats.hour,
              cte_hourly_summary_stats.brkdwn
            )
          ) AS brkdwn

        FROM cte_delays_by_quarter_hour
          LEFT OUTER JOIN cte_hourly_summary_stats
            ON (
              (cte_delays_by_quarter_hour.tmc = cte_hourly_summary_stats.tmc)
              AND
              (FLOOR(cte_delays_by_quarter_hour.quarter_hour_bin / 4) = cte_hourly_summary_stats.hour)
            )
          LEFT OUTER JOIN cte_tmc_info
            ON (cte_delays_by_quarter_hour.tmc = cte_tmc_info.tmc)
          LEFT OUTER JOIN cte_hourly_volumes ON (
            (
              FLOOR(cte_delays_by_quarter_hour.quarter_hour_bin / 4)::SMALLINT
                = cte_hourly_volumes.hour::SMALLINT
            )
            AND (cte_tmc_info.functional_class = cte_hourly_volumes.functional_class)
            AND (cte_tmc_info.congestion_level = cte_hourly_volumes.congestion_level)
            AND (cte_tmc_info.directionality = cte_hourly_volumes.directionality)
          )
        WHERE (quarter_hour_bin BETWEEN (16*4) AND (20*4 -1))
        GROUP BY cte_delays_by_quarter_hour.tmc, FLOOR(quarter_hour_bin / 4), aadt
  ) AS cte_peak_period_bins_summary_stats
  GROUP BY state, year, month, tmc
;

COMMIT;
