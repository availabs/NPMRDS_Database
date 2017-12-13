BEGIN;

COPY us.county_populations_y__YEAR__ (
  population,
  state_code,
  county_code
) FROM STDIN CSV;

CLUSTER us.county_populations_y__YEAR__ USING county_populations_y__YEAR___pkey;

COMMIT;
