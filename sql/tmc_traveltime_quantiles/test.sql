BEGIN;

DROP TABLE IF EXISTS tmp_tmc_travetime_quantiles;
DROP TABLE IF EXISTS :"STATE".tmp_tmc_travetime_quantiles;

CREATE TABLE :"STATE".tmp_tmc_travetime_quantiles AS
  SELECT
      tmc, 
      (EXTRACT(DOW FROM date)::SMALLINT % 6)::BOOLEAN AS weekday,
      epoch,
      PERCENTILE_DISC(ARRAY[0.25, 0.5, 0.75])
        WITHIN GROUP (ORDER BY travel_time_all_vehicles ASC
      )::INTEGER[3] AS quantiles
    FROM :"STATE".npmrds
    WHERE (
      (tmc IN (SELECT tmc FROM :"STATE".tmc_attributes WHERE county = 'Columbia'))
      AND
      (EXTRACT(YEAR FROM date) >= 2017)
    )
    GROUP BY tmc, weekday, epoch
;

COMMIT;
