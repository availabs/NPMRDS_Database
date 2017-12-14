BEGIN;

COPY "__STATE__".county_subdivision_populations_y__YEAR__ (
  name,
  population,
  state_code,
  county_code,
  county_subdivision_code
) FROM STDIN CSV;

CLUSTER "__STATE__".county_subdivision_populations_y__YEAR__ USING county_subdivision_populations_y__YEAR___pkey;

COMMIT;
