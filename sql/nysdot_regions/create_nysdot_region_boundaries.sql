BEGIN;

CREATE SCHEMA IF NOT EXISTS ny;

DROP TABLE IF EXISTS ny.nysdot_region_boundaries;

CREATE TABLE ny.nysdot_region_boundaries (
  region  SMALLINT PRIMARY KEY,
  name    VARCHAR(64) UNIQUE,
  geom    public.geometry(MultiPolygon, 4326)
) WITH (fillfactor=100, autovacuum_enabled=false);

INSERT INTO ny.nysdot_region_boundaries
  SELECT
      region,
      b.name,
      ST_Multi(ST_Union(c.geom)) AS geom
    FROM ny.nysdot_regions as a
      INNER JOIN ny.nysdot_region_names AS b
        USING (region)
      INNER JOIN public.tl_2017_us_county as c
        ON (a.fips_code = c.geoid)
    GROUP BY a.region, b.name;

CREATE INDEX nysdot_region_boundaries_gix
   ON ny.nysdot_region_boundaries
   USING GIST (geom);

 CLUSTER ny.nysdot_region_boundaries
   USING nysdot_region_boundaries_gix;

COMMIT;
