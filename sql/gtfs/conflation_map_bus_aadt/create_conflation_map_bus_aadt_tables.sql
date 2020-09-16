\set schema_name 'gtfs'
\set root_tbl_name :schema_name'.conflation_map_bus_aadt_':YEAR'_v':VERSION
\set tbl_name :schema_name'.conflation_map_bus_aadt_':YEAR'_':AGENCY'_v':VERSION
\set idx_name 'conflation_map_bus_aadt_':YEAR'_':AGENCY'_v':VERSION'_pkey'

BEGIN;

CREATE SCHEMA IF NOT EXISTS :schema_name;

CREATE TABLE IF NOT EXISTS :root_tbl_name (
  conflation_map_id   INTEGER,
  agency              TEXT,
  aadt                REAL,
  aadt_by_peak        JSONB,
  aadt_by_route       JSONB,

  PRIMARY KEY (conflation_map_id, agency)
) PARTITION BY LIST (agency) ;

CREATE TABLE IF NOT EXISTS :tbl_name
  PARTITION OF :root_tbl_name
  FOR VALUES IN (:'AGENCY')
  WITH (fillfactor=100)
;

ALTER TABLE :tbl_name
  ALTER COLUMN agency SET DEFAULT :'AGENCY';

CLUSTER :tbl_name USING :idx_name ;

COMMIT;
