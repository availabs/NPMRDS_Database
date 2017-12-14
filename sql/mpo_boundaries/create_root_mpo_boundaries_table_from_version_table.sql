BEGIN;

CREATE TABLE IF NOT EXISTS public.mpo_boundaries (
    LIKE us.mpo_boundaries___LATEST_VERSION__
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
