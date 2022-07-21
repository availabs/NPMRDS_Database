\set tbl_name :"STATE"'.mdd_tmc_shapes_':YEAR'_v':VERSION_TIMESTAMP
\set idx_name 'mdd_tmc_shapes_':YEAR'_v':VERSION_TIMESTAMP'_gix'                                

CREATE TABLE IF NOT EXISTS :tbl_name (
  LIKE :"STATE".mdd_tmc_shapes_:YEAR INCLUDING DEFAULTS INCLUDING CONSTRAINTS,
  PRIMARY KEY (tmc)
) ;

CREATE INDEX IF NOT EXISTS :idx_name
  ON :tbl_name
  USING GIST(wkb_geometry)
;
