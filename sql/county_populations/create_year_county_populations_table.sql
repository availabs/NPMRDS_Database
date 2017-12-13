BEGIN;

CREATE TABLE us.county_populations_y__YEAR__ (
  CONSTRAINT county_populations_y__YEAR___pkey PRIMARY KEY(state_code, county_code)
  ) INHERITS (public.county_populations)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

ALTER TABLE us.county_populations_y__YEAR__
  ALTER COLUMN year SET DEFAULT __YEAR__,
  ADD CONSTRAINT county_populations_year_chk CHECK (year = __YEAR__)
;

COMMIT;
