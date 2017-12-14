BEGIN;

CREATE TABLE IF NOT EXISTS public.urban_area_boundaries (
    LIKE us.urban_area_boundaries___LATEST_VERSION__
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
