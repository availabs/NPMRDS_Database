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

----  From the final rule:
----    Peak Period is defined as weekdays
----    from 6 a.m. to 10 a.m. and either 3 p.m.
----    to 7 p.m. or 4 p.m. to 8 p.m. State DOTs
----    and MPOs may choose whether to use
----    3 p.m. to 7 p.m. or 4 p.m. to 8 p.m. 

BEGIN;

DELETE FROM "__STATE__".phed_y__YEAR__m__MONTH__;

INSERT INTO "__STATE__".phed_y__YEAR__m__MONTH__ (
    tmc, 
    state,
    year,
    month,

    xdelay_am_peak,
    xdelay_pm_peak_1,
    xdelay_pm_peak_2,

    phed_am_peak,
    phed_pm_peak_1,
    phed_pm_peak_2,
    phed_max
  )
  WITH cte_tmc_info AS (
    SELECT
        tmc,
        aadt,
        -- miles to nearest thousandth per measure rule
        -- MAX(60% of speedlimit or 20 mph)
        -- nearest whole second
        ROUND(
          ROUND(miles::NUMERIC, 3)::NUMERIC
          /
          GREATEST(
            avg_speedlimit::NUMERIC * 0.6::NUMERIC,
            20
          )::NUMERIC
          * 
          3600::NUMERIC
        )::INTEGER AS excessive_delay_threshold_time_s,
        congestion_level,
        directionality,
        CASE WHEN (faciltype = 1)
          THEN 1
          ELSE 2
        END AS aadt_divisor,
        CASE WHEN (f_system < 3)
          THEN 'FREEWAY'::traffic_dist_functional_class_type
          ELSE 'NONFREEWAY'::traffic_dist_functional_class_type
        END AS functional_class
      FROM tmc_attributes
      WHERE (
        (NULLIF(avg_speedlimit, 0) IS NOT NULL)
        AND
        (aadt IS NOT NULL)
      )
  ), cte_vehicle_volumes AS (
      SELECT 
          congestion_level,
          directionality,
          functional_class,
          (epoch::INTEGER / 3)::INTEGER AS quarter_hour_bin,
          SUM(percent_daily_volume::NUMERIC)::NUMERIC pct_daily_vol
        FROM traffic_distributions
        WHERE day_type = 'WEEKDAY' -- PHED only concerned with weekdays
        GROUP BY
          congestion_level,
          directionality,
          functional_class,
          quarter_hour_bin
  ), cte_total_veh_xdelay_for_hour_of_day AS (
      -- At this level, we aggregate the vehicle_hour_delay, for each hour,
      --   all the 15 minute bins across the date ranges.
      SELECT
          tmc,
          quarter_hour_bin::INTEGER / 4 AS hour,
          -- Total delay for 15 min bins aggregated into hours and scaled by the aadt
          SUM(qtrhr_bin_xdelay_hrs) AS xdelay_hrs,
          SUM(
            qtrhr_bin_xdelay_hrs::NUMERIC
            * (
              cte_tmc_info.aadt::NUMERIC
              / aadt_divisor::NUMERIC -- Uni/Bi-directional AADT
              * day_of_week_adj_factor::NUMERIC
              * (cte_vehicle_volumes.pct_daily_vol::NUMERIC / 100::NUMERIC)
            )
          )::NUMERIC AS xdelay_veh_hrs
        FROM (
          SELECT
              tmc,
              day_of_week_adj_factor,
              quarter_hour_bin::INTEGER,
              -- Total delay for that 15 minute bin for the given dow adj factor
              SUM(
                ROUND(
                  (
                    --TODO TODO TODO Round this
                    GREATEST(
                      LEAST(mean_travel_time - excessive_delay_threshold_time_s, 900),
                      0
                    )::NUMERIC / 3600::NUMERIC
                  )::NUMERIC,
                  3
                )::NUMERIC
              )::NUMERIC AS qtrhr_bin_xdelay_hrs
            FROM (
              SELECT
                  tmc,
                  CASE WHEN (EXTRACT(DOW FROM date) BETWEEN 1 AND 4)
                    THEN 1.05::NUMERIC -- Monday thru Thursday
                    ELSE 1.1::NUMERIC  -- Friday (DOW = 5)
                  END AS day_of_week_adj_factor,
                  (epoch::INTEGER / 3) AS quarter_hour_bin,
                  ROUND(
                    AVG(travel_time_all_vehicles::NUMERIC)
                  )::NUMERIC AS mean_travel_time
                FROM "__STATE__".npmrds INNER JOIN cte_tmc_info USING (tmc)
                WHERE (
                  (
                    (date >= '__START_DATE__'::DATE)
                    AND
                    (date < '__END_DATE__'::DATE)
                  ) 
                  AND (
                    (epoch BETWEEN (6*12) AND (10*12 - 1)) -- 6am to 10am
                    OR
                    (epoch BETWEEN ((3+12)*12) AND ((8+12)*12 - 1)) -- 3pm to 8pm
                  )
                  AND -- Weekdays only
                    (EXTRACT(DOW FROM date) BETWEEN 1 AND 5)
                  AND -- We have sufficient info about TMC
                    (excessive_delay_threshold_time_s IS NOT NULL)
                  AND ( -- We have a valid travel time.
                    (travel_time_all_vehicles <> 0)
                    AND
                    (travel_time_all_vehicles IS NOT NULL)
                  )
                )
                GROUP BY
                  tmc,
                  date,
                  quarter_hour_bin
            ) AS sub_avg_travel_times_for_each_qtr_hr
              INNER JOIN cte_tmc_info USING (tmc)
            GROUP BY tmc, quarter_hour_bin, day_of_week_adj_factor
          ) AS sub_xdelay_hrs
        LEFT OUTER JOIN cte_tmc_info USING (tmc)
        LEFT OUTER JOIN cte_vehicle_volumes
          USING (quarter_hour_bin, functional_class, congestion_level, directionality)
      GROUP BY tmc, hour -- tmc, hour of day
  )
  SELECT
      tmc,
      '__STATE__' AS state,
      __YEAR__ AS year,
      __MONTH__ AS month,

      xdelay_am_peak::NUMERIC,
      xdelay_pm_peak_1::NUMERIC,
      xdelay_pm_peak_2::NUMERIC,

      phed_am_peak::NUMERIC,
      phed_pm_peak_1::NUMERIC,
      phed_pm_peak_2::NUMERIC,

      GREATEST(
        phed_am_peak,
        phed_pm_peak_1,
        phed_pm_peak_2
      )::NUMERIC AS phed_max

    FROM (
      SELECT
          tmc,
          SUM(xdelay_hrs)::NUMERIC AS xdelay_am_peak,
          SUM(xdelay_veh_hrs)::NUMERIC AS phed_am_peak
        FROM cte_total_veh_xdelay_for_hour_of_day
        WHERE (hour BETWEEN 6 and 9)
        GROUP BY tmc
    ) AS sub_am_peak INNER JOIN (
      SELECT
          tmc,
          SUM(xdelay_hrs)::NUMERIC AS xdelay_pm_peak_1,
          SUM(xdelay_veh_hrs)::NUMERIC AS phed_pm_peak_1
        FROM cte_total_veh_xdelay_for_hour_of_day
        WHERE (hour BETWEEN 15 and 18)
        GROUP BY tmc
    ) AS sub_pm_peak_1 USING (tmc) INNER JOIN (
      SELECT
          tmc,
          SUM(xdelay_hrs)::NUMERIC AS xdelay_pm_peak_2,
          SUM(xdelay_veh_hrs)::NUMERIC AS phed_pm_peak_2
        FROM cte_total_veh_xdelay_for_hour_of_day
        WHERE (hour BETWEEN 16 and 19)
        GROUP BY tmc
    ) AS sub_pm_peak_2 USING (tmc)
;


CLUSTER VERBOSE "__STATE__".phed_y__YEAR__m__MONTH__
  USING phed_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".phed_y__YEAR__m__MONTH__;
