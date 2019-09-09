BEGIN;

\set tbl_name 'placeholder_npmrds_shapefile_':PLACEHOLDER_YEAR
\set idx_name :tbl_name'_geom_idx'

CREATE TABLE :"STATE".:tbl_name
  AS SELECT * FROM :"STATE".npmrds_shapefile_:SOURCE_YEAR;

UPDATE :"STATE".:tbl_name SET state = UPPER(state);

ALTER TABLE :"STATE".:tbl_name
  INHERIT public.npmrds_shapefile_:PLACEHOLDER_YEAR;

CREATE INDEX :idx_name
  ON :"STATE".:tbl_name
  USING GIST (wkb_geometry);

CLUSTER :"STATE".:tbl_name
  USING :idx_name;

COMMIT;
