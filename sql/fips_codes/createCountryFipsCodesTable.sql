BEGIN;

CREATE TABLE :"COUNTRY".fips_codes (
    CONSTRAINT fips_codes_pkey PRIMARY KEY(state_code, county_code),
    CONSTRAINT country CHECK (country = :'COUNTRY')
  )
  INHERITS (public.fips_codes)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

ALTER TABLE :"COUNTRY".fips_codes
  ALTER COLUMN country SET DEFAULT :'COUNTRY';

COMMIT;
