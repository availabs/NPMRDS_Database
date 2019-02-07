BEGIN;

CREATE TABLE :"STATE".tmc_metadata (
    LIKE public.tmc_metadata INCLUDING ALL
  )
;

ALTER TABLE :"STATE".tmc_metadata
  ADD CONSTRAINT tmc_metadata_state_check CHECK (state = :'STATE'),
  INHERIT public.tmc_metadata;

END;
