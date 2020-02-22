BEGIN;

\set tbl_name 'npmrds_shapefile_':PLACEHOLDER_YEAR
\set idx_name :tbl_name'_geom_idx'
\set table_comment 'Placeholder table created by cloning ':STATE'.npmrds_shapefile_':SOURCE_YEAR

CREATE TABLE IF NOT EXISTS :"STATE".:tbl_name (
  PRIMARY KEY(tmc),
  LIKE :"STATE".npmrds_shapefile_:SOURCE_YEAR
) INHERITS (public.npmrds_shapefile_:PLACEHOLDER_YEAR);

COMMENT ON TABLE :"STATE".:tbl_name IS :'table_comment';

INSERT INTO :"STATE".:tbl_name
  SELECT * FROM :"STATE".npmrds_shapefile_:SOURCE_YEAR;

CREATE INDEX IF NOT EXISTS :idx_name
  ON :"STATE".:tbl_name
  USING GIST (wkb_geometry);

CLUSTER :"STATE".:tbl_name
  USING :idx_name;

COMMIT;
