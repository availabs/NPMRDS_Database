BEGIN;

CREATE TABLE public.county_populations (
    state_code   VARCHAR(2),
    county_code  VARCHAR(3),
    population   BIGINT,
    year         SMALLINT
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
