BEGIN;

COPY public.fips_codes (
  state,
  state_code,
  county_code,
  county
) FROM STDIN CSV;

CLUSTER public.fips_codes USING fips_codes_pkey;

COMMIT;
