DROP TABLE IF EXISTS "__STATE__".tmc_date_ranges;

CREATE TABLE "__STATE__".tmc_date_ranges (
  LIKE tmc_date_ranges INCLUDING ALL
);

INSERT INTO "__STATE__".tmc_date_ranges (tmc, first_date, last_date, state)
  SELECT tmc, 
         min(date) AS first_date, 
         max(date) AS last_date,
         '__STATE__' AS state
  FROM "__STATE__".npmrds
  GROUP BY tmc;


CREATE UNIQUE INDEX tmc_date_ranges_idx 
  ON "__STATE__".tmc_date_ranges (tmc)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".tmc_date_ranges
  ADD CONSTRAINT tmc_date_ranges_pkey PRIMARY KEY
    USING INDEX tmc_date_ranges_idx,
  ADD CONSTRAINT tmc_date_ranges_state_check CHECK(state = '__STATE__'),
  ALTER COLUMN state SET DEFAULT '__STATE__',
  INHERIT public.tmc_date_ranges;

CLUSTER VERBOSE "__STATE__".tmc_date_ranges 
  USING tmc_date_ranges_pkey;

ANALYZE VERBOSE "__STATE__".tmc_date_ranges;
