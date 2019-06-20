\set tbl_name 'tmc_identification_':YEAR'_v':DOWNLOAD_TIMESTAMP
\set idx_name :tbl_name'_geom_idx'

CREATE INDEX :idx_name
  ON :"STATE".:tbl_name
  USING GIST (wkb_geometry);

CLUSTER :"STATE".:tbl_name
  USING :idx_name;
