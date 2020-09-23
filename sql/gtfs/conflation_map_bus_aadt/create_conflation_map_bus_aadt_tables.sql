\set schema_name 'gtfs'
\set data_schema_name 'gtfs_data'
\set root_tbl_name :schema_name'.conflation_map_bus_aadt_v':VERSION
\set year_tbl_name :schema_name'.conflation_map_bus_aadt_':YEAR'_v':VERSION
\set tbl_name :data_schema_name'.conflation_map_bus_aadt_':YEAR'_':AGENCY_TRUNC'_v':VERSION
\set idx_name 'conflation_map_bus_aadt_':YEAR'_':AGENCY_TRUNC'_v':VERSION'_pkey'

BEGIN;

CREATE SCHEMA IF NOT EXISTS :schema_name;
CREATE SCHEMA IF NOT EXISTS :data_schema_name;

CREATE TABLE IF NOT EXISTS :root_tbl_name (
  conflation_map_id   INTEGER,
  year                INTEGER,
  transit_agency      TEXT,
  aadt                REAL,
  aadt_by_peak        JSONB,
  aadt_by_route       JSONB,

  PRIMARY KEY (conflation_map_id, year, transit_agency)
) PARTITION BY LIST (year) ;

CREATE TABLE IF NOT EXISTS :year_tbl_name
  PARTITION OF :root_tbl_name
  FOR VALUES IN (:YEAR)
  PARTITION BY LIST (transit_agency)
;

CREATE TABLE IF NOT EXISTS :tbl_name
  PARTITION OF :year_tbl_name
  FOR VALUES IN (:'AGENCY')
  WITH (fillfactor=100)
;

ALTER TABLE :tbl_name
  ALTER COLUMN transit_agency SET DEFAULT :'AGENCY';

ALTER TABLE :tbl_name
  ALTER COLUMN year SET DEFAULT :YEAR;

CLUSTER :tbl_name USING :idx_name ;

COMMIT;
