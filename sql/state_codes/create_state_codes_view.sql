BEGIN;

CREATE VIEW public.state_codes AS
  SELECT DISTINCT
    state,
    state_code
  FROM public.fips_codes
;

COMMIT;
