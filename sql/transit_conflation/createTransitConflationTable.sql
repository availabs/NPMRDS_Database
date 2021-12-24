-- NOTE: script variables set in ../../src/transit-conflation/load-scheduled-bus-counts
--       Kind of clunky, but done to maintain single source of truth for naming conventions.

BEGIN;

CREATE SCHEMA IF NOT EXISTS :TRANSIT_CONFLATION_SCHEMA_NAME;

CREATE TABLE IF NOT EXISTS :FULL_TABLE_NAME (
  conflation_map_id           INTEGER PRIMARY KEY,
  total_bus_counts            DOUBLE PRECISION,
  total_bus_counts_am         DOUBLE PRECISION,
  total_bus_counts_off        DOUBLE PRECISION,
  total_bus_counts_pm         DOUBLE PRECISION,
  total_bus_counts_wknd       DOUBLE PRECISION,
  total_bus_counts_ovn        DOUBLE PRECISION,
  bus_counts_by_agency_route  JSONB
) WITH (fillfactor=100, autovacuum_enabled=false) ;

CLUSTER :FULL_TABLE_NAME USING :PKEY_IDX_NAME ;

CREATE MATERIALIZED VIEW IF NOT EXISTS :FULL_AGENCY_MAP_SEGMENT_LOOKUP_MVIEW
  WITH (fillfactor=100, autovacuum_enabled=false)
  AS
    SELECT
        REGEXP_REPLACE(key, '\|.*', '') as transit_agency,
        conflation_map_id
      FROM :FULL_TABLE_NAME,
        jsonb_each(bus_counts_by_agency_route)
;

CREATE INDEX IF NOT EXISTS :AGENCY_MAP_SEGMENT_LOOKUP_MVIEW_IDX
  ON :FULL_AGENCY_MAP_SEGMENT_LOOKUP_MVIEW (transit_agency);

CLUSTER :FULL_AGENCY_MAP_SEGMENT_LOOKUP_MVIEW
  USING :AGENCY_MAP_SEGMENT_LOOKUP_MVIEW_IDX ;

CREATE OR REPLACE VIEW :AGENCY_NAMES_VIEW_FULL_NAME
  AS
    SELECT DISTINCT
        transit_agency
      FROM :FULL_AGENCY_MAP_SEGMENT_LOOKUP_MVIEW
;

COMMIT;
