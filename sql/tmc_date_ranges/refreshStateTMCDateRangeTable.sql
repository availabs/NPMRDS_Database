BEGIN;

DELETE FROM "__STATE__".tmc_date_ranges;

INSERT INTO "__STATE__".tmc_date_ranges (tmc, first_date, last_date, state)
  SELECT
      tmc, 
      min(date) AS first_date, 
      max(date) AS last_date,
      '__STATE__' AS state
  FROM "__STATE__".npmrds
  GROUP BY tmc;

CLUSTER VERBOSE "__STATE__".tmc_date_ranges 
  USING tmc_date_ranges_pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".tmc_date_ranges;
