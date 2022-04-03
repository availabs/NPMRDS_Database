BEGIN;

CREATE TABLE "__STATE__".npmrds (
  LIKE npmrds INCLUDING ALL
);

ALTER TABLE "__STATE__".npmrds
  ADD CONSTRAINT npmrds_state_check CHECK (state = '__STATE__'),
  ALTER COLUMN state SET DEFAULT '__STATE__',
  INHERIT npmrds;

END;
