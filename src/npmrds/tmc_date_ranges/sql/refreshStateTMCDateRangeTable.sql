DELETE FROM :"STATE".tmc_date_ranges;

INSERT INTO :"STATE".tmc_date_ranges (tmc, first_date, last_date, state)
  SELECT
      tmc, 
      min(date) AS first_date, 
      max(date) AS last_date,
      :'STATE' AS state
  FROM :"STATE".npmrds
  GROUP BY tmc;

CLUSTER :"STATE".tmc_date_ranges 
  USING tmc_date_ranges_pkey;

ANALYZE :"STATE".tmc_date_ranges;
