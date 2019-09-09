\set tbl_name 'npmrds_shapefile_':YEAR
\set idx_name :tbl_name'_geom_idx'

UPDATE :"STATE".:tbl_name SET state = UPPER(state);

CREATE INDEX :idx_name
  ON :"STATE".:tbl_name
  USING GIST (wkb_geometry);

CLUSTER :"STATE".:tbl_name
  USING :idx_name;
