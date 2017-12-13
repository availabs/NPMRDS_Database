BEGIN;

CREATE TABLE us.state_populations_y__YEAR__ (
  CONSTRAINT state_populations_y__YEAR___pkey PRIMARY KEY(state_code)
  ) INHERITS (public.state_populations)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

ALTER TABLE us.state_populations_y__YEAR__
  ALTER COLUMN year SET DEFAULT __YEAR__,
  ADD CONSTRAINT state_populations_year_chk CHECK (year = __YEAR__)
;

COMMIT;
