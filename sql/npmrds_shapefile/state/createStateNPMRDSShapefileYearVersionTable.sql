\set tbl_name :"STATE"'.npmrds_shapefile_':YEAR'_v':NPMRDS_SHAPEFILE_VERSION

CREATE TABLE IF NOT EXISTS :tbl_name (
  LIKE :"STATE".npmrds_shapefile_:YEAR INCLUDING ALL,
  PRIMARY KEY(tmc),
  CHECK(npmrds_shapefile_version = :'NPMRDS_SHAPEFILE_VERSION')
) WITH (fillfactor = 100, autovacuum_enabled=false);

ALTER TABLE :tbl_name
  ALTER npmrds_shapefile_version SET DEFAULT :'NPMRDS_SHAPEFILE_VERSION';
