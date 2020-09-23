\set schema_name 'gtfs'
\set root_tbl_name :schema_name'.conflation_map_bus_aadt_v':VERSION
\set view_name :schema_name'.conflation_map_bus_aadt'
\set canonical_view_name :schema_name'.bus_aadt'

BEGIN;

-- Should serve only as alias table for
--   the cannonical year/version table.
DROP VIEW IF EXISTS :view_name CASCADE;

CREATE VIEW :view_name
  AS
    SELECT
        *
      FROM :root_tbl_name
;

CREATE VIEW :canonical_view_name
  AS
    SELECT
        conflation_map_id,
        year,
        jsonb_agg(transit_agency ORDER BY transit_agency) AS agencies,
        SUM(aadt) AS aadt,
        -- TODO: use jsonb_each_text to aggregate across agencies.
        json_object_agg(
          LOWER(transit_agency),
          aadt_by_peak
        ) AS aadt_by_peak,
        json_object_agg(
          LOWER(transit_agency),
          aadt_by_route
        ) AS aadt_by_route
      FROM :view_name
      GROUP BY conflation_map_id, year
;

COMMIT;
