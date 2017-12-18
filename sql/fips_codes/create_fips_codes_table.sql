BEGIN;

CREATE TABLE public.fips_codes (
    state       VARCHAR(2),
    state_code  VARCHAR(2),
    county_code VARCHAR(3),
    county      VARCHAR,
    CONSTRAINT fips_codes_pkey PRIMARY KEY(state_code, county_code)
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
