CREATE TABLE public.npmrds_extended_shapefile_:YEAR (
  ogc_fid                  INTEGER,
  tmc                      CHARACTER VARYING,
  type                     CHARACTER VARYING,
  roadnumber               CHARACTER VARYING,
  roadname                 CHARACTER VARYING,
  firstname                CHARACTER VARYING,
  lineartmc                INTEGER,
  country                  CHARACTER VARYING,
  state                    CHARACTER VARYING,
  county                   CHARACTER VARYING,
  zip                      CHARACTER VARYING,
  direction                CHARACTER VARYING,
  startlat                 DOUBLE PRECISION,
  startlong                DOUBLE PRECISION,
  endlat                   DOUBLE PRECISION,
  endlong                  DOUBLE PRECISION,
  miles                    DOUBLE PRECISION,
  frc                      INTEGER,
  wkb_geometry             GEOMETRY(MULTILINESTRING,4326),
  npmrds_shapefile_version CHARACTER VARYING
) WITH (fillfactor=100);

-- lineartmc --renamed to tmclinear
