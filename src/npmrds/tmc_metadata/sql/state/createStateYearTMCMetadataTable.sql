CREATE TABLE IF NOT EXISTS :"STATE".tmc_metadata_:YEAR (
  CHECK (state = :'STATE')
) INHERITS (public.tmc_metadata_:YEAR)
  WITH (fillfactor=100, autovacuum_enabled=false)
;
