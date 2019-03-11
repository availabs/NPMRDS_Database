CREATE TABLE IF NOT EXISTS us.mpo_boundaries_:MPO_SHAPEFILE_VERSION (
  LIKE public.mpo_boundaries INCLUDING ALL
) WITH (fillfactor = 100, autovacuum_enabled=false);
