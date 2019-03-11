CREATE TABLE IF NOT EXISTS public.mpo_boundaries (
  ogc_fid        INTEGER NOT NULL PRIMARY KEY,
  wkb_geometry   public.geometry(MultiPolygon,4326),
  area           DOUBLE PRECISION,
  mpo_id         CHARACTER VARYING,
  mpo_name       CHARACTER VARYING,
  state          CHARACTER VARYING
) WITH (fillfactor='100', autovacuum_enabled='false');
