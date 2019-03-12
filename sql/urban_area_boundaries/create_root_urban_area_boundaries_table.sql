CREATE TABLE public.urban_area_boundaries (
    ogc_fid        INTEGER NOT NULL,
    wkb_geometry   public.geometry(MultiPolygon, 4326),
    uace10         CHARACTER VARYING,
    geoid10        CHARACTER VARYING,
    name10         CHARACTER VARYING,
    namelsad10     CHARACTER VARYING,
    lsad10         CHARACTER VARYING,
    mtfcc10        CHARACTER VARYING,
    uatyp10        CHARACTER VARYING,
    funcstat10     CHARACTER VARYING,
    aland10        DOUBLE PRECISION,
    awater10       DOUBLE PRECISION,
    intptlat10     CHARACTER VARYING,
    intptlon10     CHARACTER VARYING
) WITH (fillfactor='100', autovacuum_enabled='false');
