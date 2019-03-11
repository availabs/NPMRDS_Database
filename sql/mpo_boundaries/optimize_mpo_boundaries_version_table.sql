\set tbl_name us.mpo_boundaries_:MPO_SHAPEFILE_VERSION
\set idx_name 'us.mpo_boundaries_':MPO_SHAPEFILE_VERSION'_geom_idx'

CREATE INDEX :idx_name
  ON :tbl_name
  USING GIST (wkb_geometry);

CLUSTER :tbl_name
  USING :idx_name;

ANALYZE :tbl_name
