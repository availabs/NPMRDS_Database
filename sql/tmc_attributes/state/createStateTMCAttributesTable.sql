BEGIN;

CREATE TABLE "__STATE__".tmc_attributes (
    LIKE public.tmc_attributes INCLUDING ALL
  )
  WITH (fillfactor=100, autovacuum_enabled=false)
;

ALTER TABLE "__STATE__".tmc_attributes
  ADD PRIMARY KEY (tmc),
  ADD CONSTRAINT tmc_attributes_state_check CHECK (state = '__STATE__'),
  INHERIT public.tmc_attributes;

END;
