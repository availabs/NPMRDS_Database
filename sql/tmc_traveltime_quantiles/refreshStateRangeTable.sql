BEGIN;

DELETE FROM :"STATE".tmc_travetime_quantiles;

INSERT INTO :"STATE".tmc_travetime_quantiles
  (
    tmc,
    year,
    dow,
    epoch,
    quantiles
  )
  SELECT
      tmc, 
      EXTRACT(YEAR from date) AS year,
      EXTRACT(DOW from date) AS dow,
      epoch,
      PERCENTILE_DISC(ARRAY[0.25, 0.5, 0.75]) WITHIN GROUP (ORDER BY travel_time_all_vehicles ASC)
    FROM :"STATE".npmrds
    GROUP BY tmc, year, dow, epoch
;


CLUSTER VERBOSE :"STATE".tmc_travetime_quantiles 
  USING tmc_travetime_quantiles_pkey;

COMMIT;

ANALYZE VERBOSE :"STATE".tmc_travetime_quantiles;
