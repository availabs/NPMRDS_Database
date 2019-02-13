CREATE TABLE :"STATE".tmc_metadata_:YEAR (
  CONSTRAINT tmc_metadata_state_check CHECK (state = :'STATE')
) INHERITS (public.tmc_metadata_:YEAR)
  WITH (fillfactor=100, autovacuum_enabled=false)
;
