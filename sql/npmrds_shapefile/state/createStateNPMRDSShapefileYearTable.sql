CREATE SCHEMA IF NOT EXISTS :"STATE";

CREATE TABLE IF NOT EXISTS :"STATE".npmrds_shapefile_:YEAR (
  LIKE public.npmrds_shapefile_:YEAR INCLUDING ALL
)
  INHERITS (public.npmrds_shapefile_:YEAR);
