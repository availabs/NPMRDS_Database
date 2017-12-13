BEGIN;

CREATE TABLE us.urban_area_populations_y__YEAR__ (
  CONSTRAINT urban_area_populations_y__YEAR___pkey PRIMARY KEY(ua_code)
  ) INHERITS (public.urban_area_populations)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

ALTER TABLE us.urban_area_populations_y__YEAR__
  ALTER COLUMN year SET DEFAULT __YEAR__,
  ADD CONSTRAINT urban_area_populations_year_chk CHECK (year = __YEAR__)
;

COMMIT;
