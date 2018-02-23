BEGIN;

DELETE FROM "__STATE__".phed_y__YEAR__m__MONTH__;

INSERT INTO "__STATE__".phed_y__YEAR__m__MONTH__ (
    tmc,
    state,
    year,
    month,
    phed_am_peak,
    phed_pm1_peak,
    phed_pm2_peak,
    phed_max
  ) 
  SELECT
      sub_phed.*,
      GREATEST(
        sub_phed.phed_am_peak,
        sub_phed.phed_pm1_peak,
        sub_phed.phed_pm2_peak
      ) AS phed_max
    FROM (
      SELECT
          tmc,
          '__STATE__' AS state,
          __YEAR__ AS year,
          __MONTH__ AS month,
        ROUND(
          CAST(excessive_delay_brkdwn#>>'{PHED_AM_PEAK,total_xdelay_hrs}' AS NUMERIC),
          3
        )::REAL AS phed_am_peak,
        ROUND(
          CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_1,total_xdelay_hrs}' AS NUMERIC),
          3
        )::REAL AS phed_pm1_peak,
        ROUND(
          CAST(excessive_delay_brkdwn#>>'{PHED_PM_PEAK_2,total_xdelay_hrs}' AS NUMERIC),
          3
        )::REAL AS phed_pm2_peak

        FROM "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
    ) AS sub_phed
; 

CLUSTER VERBOSE "__STATE__".phed_y__YEAR__m__MONTH__
  USING phed_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE "__STATE__".phed_y__YEAR__m__MONTH__;
