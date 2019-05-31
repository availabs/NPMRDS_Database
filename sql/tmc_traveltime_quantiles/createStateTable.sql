BEGIN;

CREATE TABLE :"STATE".tmc_travetime_quantiles (
  LIKE tmc_travetime_quantiles INCLUDING ALL
);

INSERT INTO :"STATE".tmc_travetime_quantiles
  (
    tmc,
    weekday,
    qtr_hr,
    quantiles
  )
  SELECT
      tmc, 
      (EXTRACT(DOW FROM date)::SMALLINT % 6)::BOOLEAN AS weekday,
      (epoch / 3) AS qtr_hr,
      PERCENTILE_DISC(ARRAY[0.25, 0.5, 0.75])
        WITHIN GROUP (ORDER BY travel_time_all_vehicles ASC
      )::INTEGER[3] AS quantiles
    FROM :"STATE".npmrds
    WHERE (
      (EXTRACT(YEAR FROM date) >= 2017)
    )
    GROUP BY tmc, weekday, qtr_hr
;

;

CREATE UNIQUE INDEX tmc_travetime_quantiles_idx 
  ON :"STATE".tmc_travetime_quantiles (tmc)
  WITH (fillfactor = 100);

ALTER TABLE :"STATE".tmc_travetime_quantiles
  ADD CONSTRAINT tmc_travetime_quantiles_pkey PRIMARY KEY
    USING INDEX tmc_travetime_quantiles_idx,
  ADD CONSTRAINT tmc_travetime_quantiles_state_check CHECK(state = '__STATE__'),
  ALTER COLUMN state SET DEFAULT '__STATE__',
  INHERIT public.tmc_travetime_quantiles;

CLUSTER VERBOSE :"STATE".tmc_travetime_quantiles 
  USING tmc_travetime_quantiles_pkey;

COMMIT;

ANALYZE VERBOSE :"STATE".tmc_travetime_quantiles;
