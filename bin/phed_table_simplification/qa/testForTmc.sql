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

--  \set TMC '\'120-08103\''
--  \set TMC '\'120+08104\''
\set TMC '\'120N05942\''

BEGIN;

DROP TABLE IF EXISTS tmp_tmc_info;
CREATE TABLE IF NOT EXISTS tmp_tmc_info AS
  SELECT
      tmc,
      aadt,
      -- miles to nearest thousandth per measure rule
      -- MAX(60% of speedlimit or 20 mph)
      -- nearest whole second
      ROUND(ROUND(miles::NUMERIC, 3) / GREATEST(avg_speedlimit * 0.6, 20) * 3600)::INT AS excessive_delay_threshold_time_s,
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
    AND tmc = :TMC
;

COMMIT;

BEGIN;

DROP TABLE IF EXISTS tmp_hourly_volumes;
CREATE TABLE IF NOT EXISTS tmp_hourly_volumes AS
  SELECT 
      congestion_level,
      directionality,
      functional_class,
      FLOOR(epoch / 12)::INT AS hour,
      SUM(percent_daily_volume)::DOUBLE PRECISION pct_daily_vol -- Sum across epochs for each hour
    FROM traffic_distributions
      -- The following JOIN is specifically for QA testing
      INNER JOIN tmp_tmc_info USING (directionality, congestion_level, functional_class)
    WHERE day_type = 'WEEKDAY' -- PHED only concerned with weekdays
    GROUP BY
      congestion_level,
      directionality,
      functional_class,
      FLOOR(epoch / 12)::INT
;

--   npmrds_local=# select sum(pct_daily_vol) from tmp_hourly_volumes ;
--    sum
--   -----
--    100
--   (1 row)


COMMIT;

BEGIN;

-- At this level, we get the harmonic mean for each (date, qtr_hour_bin)
DROP TABLE IF EXISTS tmp_avg_travel_times_by_day_qtr_hr;
CREATE TABLE IF NOT EXISTS tmp_avg_travel_times_by_day_qtr_hr AS
  SELECT
      tmc,
      CASE WHEN (EXTRACT(DOW FROM date) BETWEEN 1 AND 4)
        THEN 1.05::DOUBLE PRECISION -- Monday thru Thursday
        ELSE 1.1::DOUBLE PRECISION  -- Friday (DOW = 5)
      END AS day_of_week_adj_factor,
      FLOOR(epoch / 3)::INT AS quarter_hour_bin,
      (COUNT(1)::DOUBLE PRECISION / SUM(1::DOUBLE PRECISION/travel_time_all_vehicles::DOUBLE PRECISION))::DOUBLE PRECISION AS mean_travel_time
    FROM "ny".npmrds INNER JOIN tmp_tmc_info USING (tmc)
    WHERE (
      (
        (date >= '20171201'::DATE)
        AND
        (date < '20180101'::DATE)
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
;

COMMIT;

BEGIN;

DROP TABLE IF EXISTS tmp_xdelay_hrs_agg;
CREATE TABLE IF NOT EXISTS tmp_xdelay_hrs_agg AS
  SELECT
      tmc,
      day_of_week_adj_factor,
      quarter_hour_bin::INT,
      -- Total delay for that 15 minute bin for the given dow adj factor
      SUM(
        ROUND(
          (
            GREATEST(
              LEAST(mean_travel_time - excessive_delay_threshold_time_s, 900),
              0
            )::DOUBLE PRECISION / 3600::DOUBLE PRECISION
          )::NUMERIC,
          3
        )
      )::DOUBLE PRECISION AS total_excessive_delay_hrs_for_qtr_hr_bin
    FROM tmp_avg_travel_times_by_day_qtr_hr
      INNER JOIN tmp_tmc_info USING (tmc)
    GROUP BY tmc, quarter_hour_bin, day_of_week_adj_factor
;

COMMIT;

BEGIN;

DROP TABLE IF EXISTS tmp_total_veh_xdelay_for_hour_of_day;
CREATE TABLE IF NOT EXISTS tmp_total_veh_xdelay_for_hour_of_day AS
  SELECT
      tmc,
      FLOOR(quarter_hour_bin / 4)::INT AS hour,
      -- Total delay for 15 min bins aggregated into hours and scaled by the aadt
      SUM(
        total_excessive_delay_hrs_for_qtr_hr_bin::DOUBLE PRECISION
        * (
          tmp_tmc_info.aadt::DOUBLE PRECISION
          / aadt_divisor::DOUBLE PRECISION -- Uni/Bi-directional AADT
          * day_of_week_adj_factor::DOUBLE PRECISION
          * (tmp_hourly_volumes.pct_daily_vol::DOUBLE PRECISION / 100::DOUBLE PRECISION)
          / 4::DOUBLE PRECISION /* 15mins of the hourly volume */
        )
      )::DOUBLE PRECISION AS total_vehicle_xdelay_hrs_for_hr_of_day
      FROM tmp_xdelay_hrs_agg
        LEFT OUTER JOIN tmp_tmc_info USING (tmc)
        LEFT OUTER JOIN tmp_hourly_volumes ON (
          (FLOOR(quarter_hour_bin / 4)::INT = tmp_hourly_volumes.hour::INT)
          AND (tmp_tmc_info.functional_class = tmp_hourly_volumes.functional_class)
          AND (tmp_tmc_info.congestion_level = tmp_hourly_volumes.congestion_level)
          AND (tmp_tmc_info.directionality = tmp_hourly_volumes.directionality)
        )
      WHERE (total_excessive_delay_hrs_for_qtr_hr_bin > 0) -- If delay = 0, then no effect on total
      GROUP BY tmc, FLOOR(quarter_hour_bin / 4)::INT -- tmc, hour of day
;

COMMIT;

BEGIN;

DROP TABLE IF EXISTS tmp_phed;
CREATE TABLE IF NOT EXISTS tmp_phed AS
  SELECT
      tmc,
      phed_am_peak,
      phed_pm_peak_1,
      phed_pm_peak_2
    FROM (
      SELECT
          tmc,
          SUM(total_vehicle_xdelay_hrs_for_hr_of_day) AS phed_am_peak
        FROM tmp_total_veh_xdelay_for_hour_of_day
        WHERE (hour BETWEEN 6 and 9)
        GROUP BY tmc
    ) AS tmp_am_peak INNER JOIN (
      SELECT
          tmc,
          SUM(total_vehicle_xdelay_hrs_for_hr_of_day) AS phed_pm_peak_1
        FROM tmp_total_veh_xdelay_for_hour_of_day
        WHERE (hour BETWEEN 15 and 18)
        GROUP BY tmc
    ) AS tmp_pm_peak_1 USING (tmc) INNER JOIN (
      SELECT
          tmc,
          SUM(total_vehicle_xdelay_hrs_for_hr_of_day) AS phed_pm_peak_2
        FROM tmp_total_veh_xdelay_for_hour_of_day
        WHERE (hour BETWEEN 16 and 19)
        GROUP BY tmc
    ) AS tmp_pm_peak_2 USING (tmc)
;

COMMIT;
