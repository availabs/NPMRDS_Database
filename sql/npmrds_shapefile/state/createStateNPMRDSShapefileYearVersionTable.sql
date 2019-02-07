\set tbl_name :"STATE"'.npmrds_shapefile_':YEAR'_v':NPMRDS_SHAPEFILE_VERSION

CREATE TABLE IF NOT EXISTS :tbl_name (
  LIKE :"STATE".npmrds_shapefile_:YEAR INCLUDING ALL
) WITH (fillfactor = 100);

ALTER TABLE :tbl_name
  ALTER conflation_year SET DEFAULT :YEAR,
  ALTER npmrds_shapefile_version SET DEFAULT :'NPMRDS_SHAPEFILE_VERSION';
