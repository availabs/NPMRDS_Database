CREATE TABLE IF NOT EXISTS public.npmrds_shapefile_:YEAR (
  ogc_fid                  INTEGER,
  tmc                      CHARACTER VARYING PRIMARY KEY,
  state                    CHARACTER VARYING,
  wkb_geometry             GEOMETRY(MULTILINESTRING, 4326)
) WITH (fillfactor=100);

