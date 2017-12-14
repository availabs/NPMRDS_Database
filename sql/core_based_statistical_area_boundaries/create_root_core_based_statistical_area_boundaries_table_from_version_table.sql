BEGIN;

CREATE TABLE IF NOT EXISTS public.core_based_statistical_area_boundaries (
    LIKE us.core_based_statistical_area_boundaries___LATEST_VERSION__
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
