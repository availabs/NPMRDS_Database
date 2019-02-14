\set tbl_name :"STATE"'.npmrds_shapefile_':YEAR'_v':NPMRDS_SHAPEFILE_VERSION

CREATE TABLE IF NOT EXISTS :tbl_name (
  PRIMARY KEY(tmc),
  CHECK(npmrds_shapefile_version = :'NPMRDS_SHAPEFILE_VERSION')
) INHERITS (:"STATE".npmrds_shapefile_:YEAR)
  WITH (fillfactor = 100);

ALTER TABLE :tbl_name
  ALTER npmrds_shapefile_version SET DEFAULT :'NPMRDS_SHAPEFILE_VERSION';
