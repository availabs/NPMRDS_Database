BEGIN;

CREATE TABLE IF NOT EXISTS public.county_subdivision_boundaries (
    LIKE "__STATE__".county_subdivision_boundaries___LATEST_VERSION__
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
