BEGIN;

CREATE TABLE :"STATE".tmc_date_ranges (
  LIKE tmc_date_ranges INCLUDING ALL
);

INSERT INTO :"STATE".tmc_date_ranges (tmc, first_date, last_date, state)
  SELECT tmc, 
         min(date) AS first_date, 
         max(date) AS last_date,
         :'STATE' AS state
  FROM :"STATE".npmrds
  GROUP BY tmc;


CREATE UNIQUE INDEX tmc_date_ranges_idx 
  ON :"STATE".tmc_date_ranges (tmc)
  WITH (fillfactor = 100);

ALTER TABLE :"STATE".tmc_date_ranges
  ADD CONSTRAINT tmc_date_ranges_pkey PRIMARY KEY
    USING INDEX tmc_date_ranges_idx,
  ADD CONSTRAINT tmc_date_ranges_state_check CHECK(state = :'STATE'),
  ALTER COLUMN state SET DEFAULT :'STATE',
  INHERIT public.tmc_date_ranges;

CLUSTER VERBOSE :"STATE".tmc_date_ranges 
  USING tmc_date_ranges_pkey;

COMMIT;

ANALYZE VERBOSE :"STATE".tmc_date_ranges;
