BEGIN;

DELETE FROM interstate.excessive_delay_rankings_y__YEAR__m__MONTH__;

INSERT INTO interstate.excessive_delay_rankings_y__YEAR__m__MONTH__ (
    tmc,
    year,
    month,
    am_peak_rank,
    pm1_peak_rank,
    pm2_peak_rank
  ) 
  SELECT
      tmc,
      __YEAR__ AS year,
      __MONTH__ AS month,
      RANK() OVER (ORDER BY am_peak DESC NULLS LAST) AS am_peak_rank,
      RANK() OVER (ORDER BY pm1_peak DESC NULLS LAST) AS pm1_peak_rank,
      RANK() OVER (ORDER BY pm2_peak DESC NULLS LAST) AS pm2_peak_rank
    FROM (
      SELECT
          tmc,
          __YEAR__ AS year,
          __MONTH__ AS month,
        ROUND(
          CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS NUMERIC),
          3
        ) AS am_peak,
        ROUND(
          CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS NUMERIC),
          3
        ) AS pm1_peak,
        ROUND(
          CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS NUMERIC),
          3
        ) AS pm2_peak

        FROM excessive_delay_brkdwn
        WHERE (
          (year = __YEAR__)
          AND
          (month = __MONTH__)
        )
    ) AS t
 ; 

CLUSTER VERBOSE interstate.excessive_delay_rankings_y__YEAR__m__MONTH__
  USING excessive_delay_rankings_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE interstate.excessive_delay_rankings_y__YEAR__m__MONTH__;
