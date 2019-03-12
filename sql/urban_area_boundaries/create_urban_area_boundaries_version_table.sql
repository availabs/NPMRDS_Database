CREATE TABLE IF NOT EXISTS us.urban_area_boundaries_:UA_SHAPEFILE_VERSION (
  LIKE public.urban_area_boundaries INCLUDING ALL
) WITH (fillfactor = 100, autovacuum_enabled=false);
