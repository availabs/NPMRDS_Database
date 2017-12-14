BEGIN;

CREATE TABLE public.county_subdivision_populations (
    name                    VARCHAR,
    state_code              VARCHAR(2),
    county_code             VARCHAR(3),
    county_subdivision_code VARCHAR(5),
    population              BIGINT,
    year                    SMALLINT
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
