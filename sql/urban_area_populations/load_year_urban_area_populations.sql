BEGIN;

COPY us.urban_area_populations_y__YEAR__ (
  ua_code,
  population,
  states
) FROM STDIN CSV HEADER;

CLUSTER us.urban_area_populations_y__YEAR__ USING urban_area_populations_y__YEAR___pkey;

COMMIT;
