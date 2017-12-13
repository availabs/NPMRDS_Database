BEGIN;

COPY us.urban_area_populations_y__YEAR__ (
  population,
  ua_code
) FROM STDIN CSV;

CLUSTER us.urban_area_populations_y__YEAR__ USING urban_area_populations_y__YEAR___pkey;

COMMIT;
