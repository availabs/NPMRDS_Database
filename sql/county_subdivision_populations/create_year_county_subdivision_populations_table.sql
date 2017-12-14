BEGIN;

CREATE TABLE "__STATE__".county_subdivision_populations_y__YEAR__ (
  CONSTRAINT county_subdivision_populations_y__YEAR___pkey
    PRIMARY KEY(state_code, county_code, county_subdivision_code)
  ) INHERITS (public.county_subdivision_populations)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

ALTER TABLE "__STATE__".county_subdivision_populations_y__YEAR__
  ALTER COLUMN year SET DEFAULT __YEAR__,
  ADD CONSTRAINT county_subdivision_populations_year_chk CHECK (year = __YEAR__)
;

COMMIT;
