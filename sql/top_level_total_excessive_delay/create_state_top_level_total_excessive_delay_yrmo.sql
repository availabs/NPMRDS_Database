BEGIN;

DROP TABLE IF EXISTS "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__ CASCADE;

CREATE TEMPORARY TABLE tmp_relevant_states
  ON COMMIT DROP
  AS
    SELECT
        states::VARCHAR(2)[]
      FROM geography_level_attributes_view
      WHERE (ARRAY['__STATE__']::VARCHAR(2)[] = states) -- intrastate schema
    UNION
    SELECT
        states
      FROM geography_level_attributes_view
      WHERE (
        ('__STATE__' NOT IN (SELECT state FROM state_codes))
        AND
        (array_length(states, 1) > 1) -- interstate schema
      )
;

CREATE TABLE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__ AS
  SELECT
      states,
      year,
      month,
      geography_level,
      geography_name,
      functional_class,
      am_peak_total_xdelay_hrs,
      pm1_peak_total_xdelay_hrs,
      pm2_peak_total_xdelay_hrs,
      included_mi,
      excluded_mi,
      included_tmcs_ct,
      excluded_tmcs_ct,
      summary_stats_by_phed_period,
      population_info
  FROM (
      -- State Level
      SELECT ARRAY['__STATE__']::VARCHAR(2)[] AS states,
             __YEAR__::SMALLINT AS year,
             __MONTH__::SMALLINT AS month,
             'STATE'::geography_level_type AS geography_level,
             '__STATE__'::VARCHAR AS geography_name,
             CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
               ELSE 'NONINTERSTATE'::functional_class_type
             END AS functional_class,
             am_peak_total_xdelay_hrs::DOUBLE PRECISION,
             pm1_peak_total_xdelay_hrs::DOUBLE PRECISION,
             pm2_peak_total_xdelay_hrs::DOUBLE PRECISION,
             ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
             ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
             included_tmcs_ct::INTEGER,
             excluded_tmcs_ct::INTEGER,
             JSONB_BUILD_OBJECT(
               'PHED_AM_PEAK'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  am_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(am_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(am_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(am_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(am_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(am_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(am_xdelay_per_mile_stddev::NUMERIC, 3)
                ),

               'PHED_PM_PEAK_1'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  pm1_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm1_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(pm1_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(pm1_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm1_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(pm1_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(pm1_xdelay_per_mile_stddev::NUMERIC, 3)
                ),

               'PHED_PM_PEAK_2'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  pm2_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm2_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(pm2_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(pm2_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm2_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(pm2_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(pm2_xdelay_per_mile_stddev::NUMERIC, 3)
                )
            ) AS summary_stats_by_phed_period
        FROM (
          SELECT
              is_interstate,
              SUM(miles) AS included_mi,
              COUNT(tmc) AS included_tmcs_ct,

              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS am_peak_total_xdelay_hrs,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS pm1_peak_total_xdelay_hrs,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS pm2_peak_total_xdelay_hrs,

              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS am_xdelay_sum,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS pm1_xdelay_sum,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS pm2_xdelay_sum,

              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  )
               ) AS am_xdelay_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  )
               ) AS pm1_xdelay_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                 ORDER BY CAST(
                   excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                   AS DOUBLE PRECISION
                 )
               ) AS pm2_xdelay_quartiles,

              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS am_xdelay_mean,
              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS pm1_xdelay_mean,
              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS pm2_xdelay_mean,

              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS am_xdelay_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS pm1_xdelay_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS pm2_xdelay_stddev,

              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS am_xdelay_per_mile_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS pm1_xdelay_per_mile_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS pm2_xdelay_per_mile_quartiles,

              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS am_xdelay_per_mile_mean,
              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm1_xdelay_per_mile_mean,
              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm2_xdelay_per_mile_mean,

              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS am_xdelay_per_mile_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm1_xdelay_per_mile_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm2_xdelay_per_mile_stddev

            FROM excessive_delay_brkdwn
              INNER JOIN tmc_attributes USING (tmc)
            WHERE (
              (
                (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NOT NULL)
                AND
                (
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NOT NULL)
                  OR
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NOT NULL)
                )
              )
              AND (
                (year = '__YEAR__')
                AND
                (month = '__MONTH__')
              )
              AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
            )
            GROUP BY is_interstate
        ) AS included
        FULL OUTER JOIN (
          SELECT is_interstate,
                 SUM(miles) AS excluded_mi,
                 COUNT(tmc) AS excluded_tmcs_ct
            FROM excessive_delay_brkdwn
              INNER JOIN tmc_attributes USING (tmc)
            WHERE (
              (
                (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NULL)
                OR
                (
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NULL)
                  AND
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NULL)
                )
              )
              AND (
                (year = '__YEAR__')
                AND
                (month = '__MONTH__')
              )
              AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
            )
            GROUP BY is_interstate
        ) AS excluded
        USING (is_interstate)

      UNION ALL -- Region Level

      SELECT ARRAY['__STATE__']::VARCHAR(2)[] AS states,
             __YEAR__::SMALLINT AS year,
             __MONTH__::SMALLINT AS month,
             'REGION'::geography_level_type AS geography_level,
             geography_name::VARCHAR,
             CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
               ELSE 'NONINTERSTATE'::functional_class_type
             END AS functional_class,
             am_peak_total_xdelay_hrs::DOUBLE PRECISION,
             pm1_peak_total_xdelay_hrs::DOUBLE PRECISION,
             pm2_peak_total_xdelay_hrs::DOUBLE PRECISION,
             ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
             ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
             included_tmcs_ct::INTEGER,
             excluded_tmcs_ct::INTEGER,
             JSONB_BUILD_OBJECT(
               'PHED_AM_PEAK'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  am_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(am_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(am_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(am_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(am_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(am_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(am_xdelay_per_mile_stddev::NUMERIC, 3)
                ),

               'PHED_PM_PEAK_1'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  pm1_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm1_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(pm1_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(pm1_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm1_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(pm1_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(pm1_xdelay_per_mile_stddev::NUMERIC, 3)
                ),

               'PHED_PM_PEAK_2'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  pm2_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm2_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(pm2_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(pm2_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm2_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(pm2_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(pm2_xdelay_per_mile_stddev::NUMERIC, 3)
                )
            ) AS summary_stats_by_phed_period
        FROM (
          SELECT 
              region_name AS geography_name,
              is_interstate,
              SUM(miles) AS included_mi,
              COUNT(tmc) AS included_tmcs_ct,

              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS am_peak_total_xdelay_hrs,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS pm1_peak_total_xdelay_hrs,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS pm2_peak_total_xdelay_hrs,

              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS am_xdelay_sum,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS pm1_xdelay_sum,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS pm2_xdelay_sum,

              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  )
               ) AS am_xdelay_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  )
               ) AS pm1_xdelay_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                 ORDER BY CAST(
                   excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                   AS DOUBLE PRECISION
                 )
               ) AS pm2_xdelay_quartiles,

              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS am_xdelay_mean,
              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS pm1_xdelay_mean,
              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS pm2_xdelay_mean,

              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS am_xdelay_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS pm1_xdelay_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS pm2_xdelay_stddev,

              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS am_xdelay_per_mile_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS pm1_xdelay_per_mile_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS pm2_xdelay_per_mile_quartiles,

              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS am_xdelay_per_mile_mean,
              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm1_xdelay_per_mile_mean,
              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm2_xdelay_per_mile_mean,

              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS am_xdelay_per_mile_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm1_xdelay_per_mile_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm2_xdelay_per_mile_stddev

            FROM excessive_delay_brkdwn
              INNER JOIN tmc_attributes USING (tmc)
            WHERE (
              (
                (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NOT NULL)
                AND
                (
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NOT NULL)
                  OR
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NOT NULL)
                )
              )
              AND (region_name IS NOT NULL)
              AND (
                (year = '__YEAR__')
                AND
                (month = '__MONTH__')
              )
              AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
            )
            GROUP BY geography_name, is_interstate
        ) AS included
        FULL OUTER JOIN (
          SELECT region_name AS geography_name,
                 is_interstate,
                 SUM(miles) AS excluded_mi,
                 COUNT(tmc) AS excluded_tmcs_ct
            FROM excessive_delay_brkdwn
              INNER JOIN tmc_attributes USING(tmc)
            WHERE (
              (
                (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NULL)
                OR
                (
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NULL)
                  AND
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NULL)
                )
              )
              AND (region_name IS NOT NULL)
              AND (
                (year = '__YEAR__')
                AND
                (month = '__MONTH__')
              )
              AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
            )
            GROUP BY geography_name, is_interstate
        ) AS excluded
        USING (geography_name, is_interstate)

      UNION ALL -- County Level

      SELECT ARRAY['__STATE__']::VARCHAR(2)[] AS states,
             __YEAR__::SMALLINT AS year,
             __MONTH__::SMALLINT AS month,
             'COUNTY'::geography_level_type AS geography_level,
             geography_name::VARCHAR,
             CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
               ELSE 'NONINTERSTATE'::functional_class_type
             END AS functional_class,
             am_peak_total_xdelay_hrs::DOUBLE PRECISION,
             pm1_peak_total_xdelay_hrs::DOUBLE PRECISION,
             pm2_peak_total_xdelay_hrs::DOUBLE PRECISION,
             ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
             ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
             included_tmcs_ct::INTEGER,
             excluded_tmcs_ct::INTEGER,
             JSONB_BUILD_OBJECT(
               'PHED_AM_PEAK'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  am_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(am_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(am_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(am_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(am_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(am_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(am_xdelay_per_mile_stddev::NUMERIC, 3)
                ),

               'PHED_PM_PEAK_1'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  pm1_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm1_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(pm1_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(pm1_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm1_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(pm1_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(pm1_xdelay_per_mile_stddev::NUMERIC, 3)
                ),

               'PHED_PM_PEAK_2'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  pm2_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm2_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(pm2_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(pm2_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm2_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(pm2_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(pm2_xdelay_per_mile_stddev::NUMERIC, 3)
                )
            ) AS summary_stats_by_phed_period
        FROM (
          SELECT
              county AS geography_name,
              is_interstate,
              SUM(miles) AS included_mi,
              COUNT(tmc) AS included_tmcs_ct,

              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS am_peak_total_xdelay_hrs,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS pm1_peak_total_xdelay_hrs,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS pm2_peak_total_xdelay_hrs,

              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS am_xdelay_sum,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS pm1_xdelay_sum,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS pm2_xdelay_sum,

              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  )
               ) AS am_xdelay_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  )
               ) AS pm1_xdelay_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                 ORDER BY CAST(
                   excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                   AS DOUBLE PRECISION
                 )
               ) AS pm2_xdelay_quartiles,

              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS am_xdelay_mean,
              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS pm1_xdelay_mean,
              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS pm2_xdelay_mean,

              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS am_xdelay_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS pm1_xdelay_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS pm2_xdelay_stddev,

              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS am_xdelay_per_mile_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS pm1_xdelay_per_mile_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS pm2_xdelay_per_mile_quartiles,

              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS am_xdelay_per_mile_mean,
              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm1_xdelay_per_mile_mean,
              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm2_xdelay_per_mile_mean,

              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS am_xdelay_per_mile_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm1_xdelay_per_mile_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm2_xdelay_per_mile_stddev

            FROM excessive_delay_brkdwn
              INNER JOIN tmc_attributes USING (tmc)
            WHERE (
              (
                (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NOT NULL)
                AND
                (
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NOT NULL)
                  OR
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NOT NULL)
                )
              )
              AND (county IS NOT NULL)
              AND (
                (year = '__YEAR__')
                AND
                (month = '__MONTH__')
              )
              AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
            )
            GROUP BY geography_name, is_interstate
        ) AS included
        FULL OUTER JOIN (
          SELECT county AS geography_name,
                 is_interstate,
                 SUM(miles) AS excluded_mi,
                 COUNT(tmc) AS excluded_tmcs_ct
            FROM excessive_delay_brkdwn
            INNER JOIN tmc_attributes USING(tmc)
            WHERE (
              (
                (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NULL)
                OR
                (
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NULL)
                  AND
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NULL)
                )
              ) 
              AND (county IS NOT NULL)
              AND (
                (year = '__YEAR__')
                AND
                (month = '__MONTH__')
              )
              AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
            )
            GROUP BY geography_name, is_interstate
        ) AS excluded
        USING (geography_name, is_interstate)

      UNION ALL -- UA Level

      SELECT states,
             __YEAR__::SMALLINT AS year,
             __MONTH__::SMALLINT AS month,
             'UA'::geography_level_type AS geography_level,
             geography_name::VARCHAR,
             CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
               ELSE 'NONINTERSTATE'::functional_class_type
             END AS functional_class,
             am_peak_total_xdelay_hrs::DOUBLE PRECISION,
             pm1_peak_total_xdelay_hrs::DOUBLE PRECISION,
             pm2_peak_total_xdelay_hrs::DOUBLE PRECISION,
             ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
             ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
             included_tmcs_ct::INTEGER,
             excluded_tmcs_ct::INTEGER,
             JSONB_BUILD_OBJECT(
               'PHED_AM_PEAK'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  am_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(am_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(am_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(am_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(am_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(am_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(am_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(am_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(am_xdelay_per_mile_stddev::NUMERIC, 3)
                ),

               'PHED_PM_PEAK_1'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  pm1_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm1_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(pm1_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(pm1_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(pm1_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm1_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(pm1_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(pm1_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(pm1_xdelay_per_mile_stddev::NUMERIC, 3)
                ),

               'PHED_PM_PEAK_2'::phed_peak_period_type,
                JSONB_BUILD_OBJECT(
                  'xdelay_sum',
                  pm2_xdelay_sum,

                  'xdelay_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm2_xdelay_quartiles[1]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[2]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[3]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[4]::NUMERIC, 3),
                    ROUND(pm2_xdelay_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_mean',
                  ROUND(pm2_xdelay_mean::NUMERIC, 3),

                  'xdelay_stddev',
                  ROUND(pm2_xdelay_stddev::NUMERIC, 3),

                  'xdelay_per_mile_quartiles',
                  JSONB_BUILD_ARRAY(
                    ROUND(pm2_xdelay_per_mile_quartiles[1]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[2]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[3]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[4]::NUMERIC, 3),
                    ROUND(pm2_xdelay_per_mile_quartiles[5]::NUMERIC, 3)
                  ),

                  'xdelay_per_mile_mean',
                  ROUND(pm2_xdelay_per_mile_mean::NUMERIC, 3),

                  'xdelay_per_mile_stddev',
                  ROUND(pm2_xdelay_per_mile_stddev::NUMERIC, 3)
                )
            ) AS summary_stats_by_phed_period
        FROM (
          SELECT
              ua_name AS geography_name,
              is_interstate,
              SUM(miles) AS included_mi,
              COUNT(tmc) AS included_tmcs_ct,

              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS am_peak_total_xdelay_hrs,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS pm1_peak_total_xdelay_hrs,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
                  * occupancy_factor
                )::NUMERIC,
                3
              ) AS pm2_peak_total_xdelay_hrs,

              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS am_xdelay_sum,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS pm1_xdelay_sum,
              ROUND(
                SUM(
                  CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
                )::NUMERIC,
                3
              ) AS pm2_xdelay_sum,

              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  )
               ) AS am_xdelay_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  )
               ) AS pm1_xdelay_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                 ORDER BY CAST(
                   excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                   AS DOUBLE PRECISION
                 )
               ) AS pm2_xdelay_quartiles,

              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS am_xdelay_mean,
              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS pm1_xdelay_mean,
              AVG(
                CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS DOUBLE PRECISION)
              ) AS pm2_xdelay_mean,

              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS am_xdelay_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS pm1_xdelay_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                )
              ) AS pm2_xdelay_stddev,

              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS am_xdelay_per_mile_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS pm1_xdelay_per_mile_quartiles,
              PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
                WITHIN GROUP (
                  ORDER BY CAST(
                    excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                    AS DOUBLE PRECISION
                  ) / miles
                ) AS pm2_xdelay_per_mile_quartiles,

              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS am_xdelay_per_mile_mean,
              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm1_xdelay_per_mile_mean,
              AVG(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm2_xdelay_per_mile_mean,

              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS am_xdelay_per_mile_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm1_xdelay_per_mile_stddev,
              STDDEV_POP(
                CAST(
                  excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}'
                  AS DOUBLE PRECISION
                ) / miles
              ) AS pm2_xdelay_per_mile_stddev,

              tmp_relevant_states.states

            FROM excessive_delay_brkdwn
              INNER JOIN tmc_attributes USING (tmc)
              INNER JOIN tmp_relevant_states ON (tmc_attributes.state = ANY(tmp_relevant_states.states))
              INNER JOIN geography_level_attributes_view ON (
                (tmc_attributes.ua_name = geography_level_attributes_view.geography_level_name)
                AND
                (tmp_relevant_states.states = geography_level_attributes_view.states)
              )
            WHERE (
              (
                (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NOT NULL)
                AND
                (
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NOT NULL)
                  OR
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NOT NULL)
                )
              )
              AND (ua_name IS NOT NULL)
              AND (
                (year = '__YEAR__')
                AND
                (month = '__MONTH__')
              )
            )
            GROUP BY geography_name, is_interstate, tmp_relevant_states.states
        ) AS included
        FULL OUTER JOIN (
          SELECT ua_name AS geography_name,
                 is_interstate,
                 SUM(miles) AS excluded_mi,
                 COUNT(tmc) AS excluded_tmcs_ct,
                 tmp_relevant_states.states
            FROM excessive_delay_brkdwn
              INNER JOIN tmc_attributes USING(tmc)
              INNER JOIN tmp_relevant_states ON (tmc_attributes.state = ANY(tmp_relevant_states.states))
              INNER JOIN geography_level_attributes_view ON (
                (tmc_attributes.ua_name = geography_level_attributes_view.geography_level_name)
                AND
                (tmp_relevant_states.states = geography_level_attributes_view.states)
              )
            WHERE (
              (
                (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NULL)
                OR
                (
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NULL)
                  AND
                  (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NULL)
                )
              )
              AND (ua_name IS NOT NULL)
              AND (
                (year = '__YEAR__')
                AND
                (month = '__MONTH__')
              )
            )
            GROUP BY geography_name, is_interstate, tmp_relevant_states.states
        ) AS excluded
        USING (geography_name, is_interstate, states)
    ) AS sub_xdelay_brkdwn_data
    NATURAL LEFT OUTER JOIN (
      SELECT
          geography_level,
          geography_level_name AS geography_name,
          states,
          JSONB_Build_Object(
            year,
            pop_info
          ) AS population_info
        FROM (
          SELECT
              geography_level,
              geography_level_name,
              states,
              CAST((pop_info).key AS INT) AS year,
              CAST((pop_info).value AS JSONB) AS pop_info,
              RANK() OVER (
                PARTITION BY geography_level, geography_level_name, states
                  ORDER BY
                    ABS(__YEAR__ - CAST((pop_info).key AS INT)) ASC,
                    CAST((pop_info).key AS INT) DESC
              ) AS rank
            FROM (
              SELECT
                  geography_level,
                  geography_level_name,
                  states,
                  jsonb_each(population_info) AS pop_info
                FROM geography_level_attributes_view
            ) AS t1
        ) AS t2
        WHERE (
          (states IN (SELECT states FROM tmp_relevant_states))
          AND
          (rank = 1)
        )
      ) AS sub_closest_year_population_info
;


INSERT INTO "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__ (
    states,
    year,
    month,
    geography_level,
    geography_name,
    functional_class,
    am_peak_total_xdelay_hrs,
    pm1_peak_total_xdelay_hrs,
    pm2_peak_total_xdelay_hrs,
    included_mi,
    excluded_mi,
    included_tmcs_ct,
    excluded_tmcs_ct,
    summary_stats_by_phed_period,
    population_info
  )
  SELECT
      sub_ua_data.states,
      sub_ua_data.year,
      sub_ua_data.month,
      'MPO' AS geography_level,
      COALESCE(
        mpo_boundaries_view.mpo_acrony,
        mpo_boundaries_view.mpo_name
      ) AS geography_name,
      sub_ua_data.functional_class,
      sub_ua_data.am_peak_total_xdelay_hrs,
      sub_ua_data.pm1_peak_total_xdelay_hrs,
      sub_ua_data.pm2_peak_total_xdelay_hrs,
      sub_ua_data.included_mi,
      sub_ua_data.excluded_mi,
      sub_ua_data.included_tmcs_ct,
      sub_ua_data.excluded_tmcs_ct,
      sub_ua_data.summary_stats_by_phed_period,
      sub_ua_data.mpo_pop_info AS population_info
    FROM (
			SELECT
					d.*,
					jsonb_build_object(
						key,
						jsonb_set(
							jsonb_set(
								population_info->key,
                '{0, geography_level}',
								'"UA"',
								true
							),
							'{0, geography_name}',
							('"'||d.geography_name||'"')::JSONB,
							true
						)
					) AS mpo_pop_info
				FROM "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__ AS d,
					LATERAL (
						SELECT CAST(MAX(year) AS TEXT) AS key
							FROM CAST(jsonb_object_keys(d.population_info) AS INT) AS x(year)
					) AS y
				WHERE (
					(geography_level = 'UA'::geography_level_type)
					AND
					(key IS NOT NULL) -- is this needed???
				)
      ) AS sub_ua_data
      -- Because top_level_total_excessive_delay has geoNames but not ids.
      INNER JOIN urban_area_boundaries sub_ua_bnds ON (
        sub_ua_data.geography_name = sub_ua_bnds.name10
      ) 
      -- Use the mpo_to_ua table to associate MPOs and UAs
      INNER JOIN mpo_to_ua ON (
        sub_ua_bnds.geoid10 = mpo_to_ua.ua_code 
      )
      -- Get the Acronym (the prefered handle)
      LEFT OUTER JOIN mpo_boundaries_view ON (
        mpo_to_ua.mpo_code = mpo_boundaries_view.mpo_id
      )
    WHERE (mpo_boundaries_view.state = ANY(sub_ua_data.states::VARCHAR(2)[]))
;
  
  
ALTER TABLE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__
  ADD CONSTRAINT state_check CHECK (
    (states = ARRAY['__STATE__']::VARCHAR(2)[]) OR (ARRAY_LENGTH(states, 1) > 1)
  ),
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  INHERIT "__STATE__".top_level_total_excessive_delay,
  SET (fillfactor = 100);


CREATE UNIQUE INDEX top_level_excessive_delay_y__YEAR__m__MONTH___idx
  ON "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__ 
    (geography_level, geography_name, functional_class)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__
  ADD CONSTRAINT top_level_excessive_delay_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX top_level_excessive_delay_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__
  USING top_level_excessive_delay_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__;
