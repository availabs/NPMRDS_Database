BEGIN;

CREATE TABLE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__ AS

  -- State Level
  SELECT '__STATE__'::VARCHAR(2) AS state,
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

        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING (tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NOT NULL)
            AND
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NOT NULL)
              OR
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NOT NULL)
            )
          )
        GROUP BY is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING (tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NULL)
            OR
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NULL)
              AND
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NULL)
            )
          )
        GROUP BY is_interstate
    ) AS excluded
    USING (is_interstate)

  UNION ALL -- Region Level

  SELECT '__STATE__'::VARCHAR(2) AS state,
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

        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING (tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NOT NULL)
            AND
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NOT NULL)
              OR
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NOT NULL)
            )
          ) AND (region_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT region_name AS geography_name,
             is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
        INNER JOIN tmc_attributes USING(tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NULL)
            OR
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NULL)
              AND
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NULL)
            )
          ) AND (region_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS excluded
    USING (geography_name, is_interstate)

  UNION ALL -- County Level

  SELECT '__STATE__'::VARCHAR(2) AS state,
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

        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING (tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NOT NULL)
            AND
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NOT NULL)
              OR
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NOT NULL)
            )
          ) AND (county IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT county AS geography_name,
             is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
        INNER JOIN tmc_attributes USING(tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NULL)
            OR
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NULL)
              AND
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NULL)
            )
          ) AND (county IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS excluded
    USING (geography_name, is_interstate)

  UNION ALL -- MPO Level

  SELECT '__STATE__'::VARCHAR(2) AS state,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'MPO'::geography_level_type AS geography_level,
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
          mpo_name AS geography_name,
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

        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING (tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NOT NULL)
            AND
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NOT NULL)
              OR
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NOT NULL)
            )
          ) AND (mpo_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT mpo_name AS geography_name,
             is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING(tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NULL)
            OR
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NULL)
              AND
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NULL)
            )
          ) AND (mpo_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS excluded
    USING (geography_name, is_interstate)

  UNION ALL -- CBSA Level

  SELECT '__STATE__'::VARCHAR(2) AS state,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'CBSA'::geography_level_type AS geography_level,
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
          cbsa_name AS geography_name,
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

        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING (tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NOT NULL)
            AND
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NOT NULL)
              OR
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NOT NULL)
            )
          ) AND (cbsa_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT cbsa_name AS geography_name,
             is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING(tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NULL)
            OR
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NULL)
              AND
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NULL)
            )
          ) AND (cbsa_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS excluded
    USING (geography_name, is_interstate)

  UNION ALL -- UA Level

  SELECT '__STATE__'::VARCHAR(2) AS state,
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
          ) AS pm2_xdelay_per_mile_stddev

        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING (tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NOT NULL)
            AND
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NOT NULL)
              OR
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NOT NULL)
            )
          ) AND (ua_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT ua_name AS geography_name,
             is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING(tmc)
        WHERE (
            (excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' IS NULL)
            OR
            (
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' IS NULL)
              AND
              (excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' IS NULL)
            )
          ) AND (ua_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS excluded
    USING (geography_name, is_interstate)
  ;
  

ALTER TABLE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__
  ADD CONSTRAINT state_check 
    CHECK (state = '__STATE__'),
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
