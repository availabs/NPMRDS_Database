BEGIN;

CREATE TABLE public.county_populations (
      usps         VARCHAR,
      geoid        VARCHAR,
      ansicode     VARCHAR,
      name         VARCHAR,
      pop10        BIGINT,
      hu10         BIGINT,
      aland        DOUBLE PRECISION,
      awater       DOUBLE PRECISION,
      aland_sqmi   DOUBLE PRECISION,
      awater_sqmi  DOUBLE PRECISION,
      intptlat     DOUBLE PRECISION,
      intptlong    DOUBLE PRECISION,
    CONSTRAINT county_populations_pkey PRIMARY KEY(geoid)
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
