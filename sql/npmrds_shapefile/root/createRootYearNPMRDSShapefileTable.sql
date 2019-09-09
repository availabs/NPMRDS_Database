CREATE TABLE public.npmrds_shapefile_:YEAR (
  ogc_fid                  INTEGER,
  tmc                      CHARACTER VARYING,
  state                    CHARACTER VARYING,
  wkb_geometry             GEOMETRY(MULTILINESTRING, 4326)
) WITH (fillfactor=100);

