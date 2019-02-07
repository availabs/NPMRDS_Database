BEGIN;

CREATE TABLE :"STATE".tmc_metadata_:YEAR (
    LIKE :"STATE".tmc_metadata INCLUDING ALL
  )
  WITH (fillfactor=100, autovacuum_enabled=false)
;

ALTER TABLE :"STATE".tmc_metadata_:YEAR
  ADD PRIMARY KEY (tmc),
  ADD CONSTRAINT tmc_metadata_year_check CHECK (conflation_year = :YEAR),
  INHERIT :"STATE".tmc_metadata ;

COMMIT;
