BEGIN;

DELETE FROM interstate.tttr_percentiles_rankings_y__YEAR__m__MONTH__;

INSERT INTO interstate.tttr_percentiles_rankings_y__YEAR__m__MONTH__ (
    tmc,
    year,
    month,
    am_peak_rank,
    midday_rank,
    pm_peak_rank,
    weekend_rank,
    overnight_rank
  ) 
  SELECT
      tmc,
      __YEAR__ AS year,
      __MONTH__ AS month,
      RANK() OVER (ORDER BY am_peak DESC NULLS LAST) AS am_peak_rank,
      RANK() OVER (ORDER BY midday DESC NULLS LAST) AS midday_rank,
      RANK() OVER (ORDER BY pm_peak DESC NULLS LAST) AS pm_peak_rank,
      RANK() OVER (ORDER BY weekend DESC NULLS LAST) AS weekend_rank,
      RANK() OVER (ORDER BY overnight DESC NULLS LAST) AS overnight_rank
    FROM (
      SELECT
          tmc,
          __YEAR__ AS year,
          __MONTH__ AS month,
          (
            ((data->'AM_PEAK')->1)::TEXT::REAL
            / NULLIF(((data->'AM_PEAK')->0)::TEXT::REAL, 0)
          ) AS am_peak,
          (
            ((data->'MIDDAY')->1)::TEXT::NUMERIC
            / NULLIF(((data->'MIDDAY')->0)::TEXT::NUMERIC, 0)
          ) AS midday,
          (
            ((data->'PM_PEAK')->1)::TEXT::NUMERIC
            / NULLIF(((data->'PM_PEAK')->0)::TEXT::NUMERIC, 0)
          ) AS pm_peak,
          (
            ((data->'WEEKEND')->1)::TEXT::NUMERIC
            / NULLIF(((data->'WEEKEND')->0)::TEXT::NUMERIC, 0)
          ) AS weekend,
          (
            ((data->'OVERNIGHT')->1)::TEXT::NUMERIC
            / NULLIF(((data->'OVERNIGHT')->0)::TEXT::NUMERIC, 0)
          ) AS overnight
        FROM tttr_percentiles
        WHERE (
          (year = __YEAR__)
          AND
          (month = __MONTH__)
        )
    ) AS t
 ; 

CLUSTER VERBOSE interstate.tttr_percentiles_rankings_y__YEAR__m__MONTH__
  USING tttr_percentiles_rankings_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE interstate.tttr_percentiles_rankings_y__YEAR__m__MONTH__;
