\set tbl_name 'npmrds_shapefile_':YEAR'_v':NPMRDS_SHAPEFILE_VERSION
\set idx_name :tbl_name'_geom_idx'

ALTER TABLE :"STATE".:tbl_name
  INHERIT :"STATE".npmrds_shapefile_:YEAR;

CREATE INDEX :idx_name
  ON :"STATE".:tbl_name
  USING GIST (wkb_geometry);

CLUSTER :"STATE".:tbl_name
  USING :idx_name;
