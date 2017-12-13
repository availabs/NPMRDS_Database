BEGIN;

CREATE TABLE public.urban_area_populations (
    ua_code     VARCHAR,
    population  BIGINT,
    year        SMALLINT
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
