BEGIN;

CREATE VIEW public.state_codes AS
  SELECT DISTINCT
    state,
    state_code,
    country
  FROM public.fips_codes
;

COMMIT;
