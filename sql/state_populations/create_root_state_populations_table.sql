BEGIN;

CREATE TABLE public.state_populations (
    state_code  VARCHAR(2),
    population  BIGINT,
    year        SMALLINT
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
