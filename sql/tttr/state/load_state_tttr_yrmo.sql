BEGIN;

DELETE FROM "__STATE__".tttr_y__YEAR__m__MONTH__;

INSERT INTO "__STATE__".tttr_y__YEAR__m__MONTH__ (
    tmc,
    state,
    year,
    month,
    tttr_am_peak,
    tttr_midday,
    tttr_pm_peak,
    tttr_weekend,
    tttr_overnight,
    tttr_max
  ) 
  SELECT
      sub_tttr.*,
      GREATEST(
        sub_tttr.tttr_am_peak,
        sub_tttr.tttr_midday,
        sub_tttr.tttr_pm_peak,
        sub_tttr.tttr_weekend,
        sub_tttr.tttr_overnight
      ) AS tttr_max
    FROM (
      SELECT
          tmc,
          '__STATE__' AS state,
          __YEAR__ AS year,
          __MONTH__ AS month,
          (
            ((data->'AM_PEAK')->1)::TEXT::REAL
            / NULLIF(((data->'AM_PEAK')->0)::TEXT::REAL, 0)
          )::REAL AS tttr_am_peak,
          (
            ((data->'MIDDAY')->1)::TEXT::NUMERIC
            / NULLIF(((data->'MIDDAY')->0)::TEXT::NUMERIC, 0)
          )::REAL AS tttr_midday,
          (
            ((data->'PM_PEAK')->1)::TEXT::NUMERIC
            / NULLIF(((data->'PM_PEAK')->0)::TEXT::NUMERIC, 0)
          )::REAL AS tttr_pm_peak,
          (
            ((data->'WEEKEND')->1)::TEXT::NUMERIC
            / NULLIF(((data->'WEEKEND')->0)::TEXT::NUMERIC, 0)
          )::REAL AS tttr_weekend,
          (
            ((data->'OVERNIGHT')->1)::TEXT::NUMERIC
            / NULLIF(((data->'OVERNIGHT')->0)::TEXT::NUMERIC, 0)
          )::REAL AS tttr_overnight
        FROM "__STATE__".tttr_percentiles_y__YEAR__m__MONTH__
    ) AS sub_tttr
 ; 

CLUSTER VERBOSE "__STATE__".tttr_y__YEAR__m__MONTH__
  USING tttr_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".tttr_y__YEAR__m__MONTH__;
