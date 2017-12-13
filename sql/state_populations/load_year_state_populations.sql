BEGIN;

COPY us.state_populations_y__YEAR__ (
  population,
  state_code
) FROM STDIN CSV;

CLUSTER us.state_populations_y__YEAR__ USING state_populations_y__YEAR___pkey;

COMMIT;
