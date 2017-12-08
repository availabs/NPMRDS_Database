BEGIN;

CREATE TABLE public.urban_area_populations (
      geoid        VARCHAR(5),
      name         VARCHAR,
      uatype       CHAR,
      pop10        BIGINT,
      hu10         BIGINT,
      aland        DOUBLE PRECISION,
      awater       DOUBLE PRECISION,
      aland_sqmi   DOUBLE PRECISION,
      awater_sqmi  DOUBLE PRECISION,
      intptlat     DOUBLE PRECISION,
      intptlong    DOUBLE PRECISION,
    CONSTRAINT urban_area_populations_pkey PRIMARY KEY(geoid)
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
