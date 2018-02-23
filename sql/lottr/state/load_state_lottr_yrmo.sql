BEGIN;

DELETE FROM "__STATE__".lottr_y__YEAR__m__MONTH__;

INSERT INTO "__STATE__".lottr_y__YEAR__m__MONTH__ (
    tmc,
    state,
    year,
    month,
    lottr_am_peak,
    lottr_midday,
    lottr_pm_peak,
    lottr_weekend,
    lottr_max
  ) 
  SELECT
      sub_lottr.*,
      GREATEST(
        sub_lottr.lottr_am_peak,
        sub_lottr.lottr_midday,
        sub_lottr.lottr_pm_peak,
        sub_lottr.lottr_weekend
      ) AS lottr_max
    FROM (
      SELECT
          tmc,
          '__STATE__' AS state,
          __YEAR__ AS year,
          __MONTH__ AS month,
          (
            ((data->'AM_PEAK')->1)::TEXT::REAL
            / NULLIF(((data->'AM_PEAK')->0)::TEXT::REAL, 0)
          )::REAL AS lottr_am_peak,
          (
            ((data->'MIDDAY')->1)::TEXT::NUMERIC
            / NULLIF(((data->'MIDDAY')->0)::TEXT::NUMERIC, 0)
          )::REAL AS lottr_midday,
          (
            ((data->'PM_PEAK')->1)::TEXT::NUMERIC
            / NULLIF(((data->'PM_PEAK')->0)::TEXT::NUMERIC, 0)
          )::REAL AS lottr_pm_peak,
          (
            ((data->'WEEKEND')->1)::TEXT::NUMERIC
            / NULLIF(((data->'WEEKEND')->0)::TEXT::NUMERIC, 0)
          )::REAL AS lottr_weekend
        FROM "__STATE__".lottr_percentiles_y__YEAR__m__MONTH__
    ) AS sub_lottr
 ; 

CLUSTER VERBOSE "__STATE__".lottr_y__YEAR__m__MONTH__
  USING lottr_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".lottr_y__YEAR__m__MONTH__;
