BEGIN;

DROP MATERIALIZED VIEW IF EXISTS highway_data_services.regions_to_stations CASCADE;

CREATE MATERIALIZED VIEW highway_data_services.regions_to_stations
WITH (fillfactor = 100, autovacuum_enabled = false)
AS
  SELECT DISTINCT
      rg::SMALLINT AS region,
      rc_station::VARCHAR AS station_id,
      'average_weekday_speed' AS table_name
    FROM highway_data_services.average_weekday_speed
  UNION
  SELECT DISTINCT
      rg::SMALLINT AS region,
      rc_station::VARCHAR AS station_id,
      'average_weekday_vehicle_classification' AS table_name
    FROM highway_data_services.average_weekday_vehicle_classification
  UNION
  SELECT DISTINCT
      rg::SMALLINT AS region,
      rc_station::VARCHAR AS station_id,
      'average_weekday_volume' AS table_name
    FROM highway_data_services.average_weekday_volume

  UNION
  SELECT DISTINCT
      region::SMALLINT AS region,
      (rc || '_' || station)::VARCHAR AS station_id,
      'continuous_vehicle_classification' AS table_name
    FROM highway_data_services.continuous_vehicle_classification
  UNION
  SELECT DISTINCT
      region::SMALLINT AS region,
      (rc || '_' || station)::VARCHAR AS station_id,
      'continuous_volume' AS table_name
    FROM highway_data_services.continuous_volume

  UNION
  SELECT DISTINCT
      rg::SMALLINT AS region,
      rc_station::VARCHAR AS station_id,
      'short_count_speed' AS table_name
    FROM highway_data_services.short_count_speed
  UNION
  SELECT DISTINCT
      rg::SMALLINT AS region,
      rc_station::VARCHAR AS station_id,
      'short_count_vehicle_classification' AS table_name
    FROM highway_data_services.short_count_vehicle_classification
  UNION
  SELECT DISTINCT
      rg::SMALLINT AS region,
      rc_station::VARCHAR AS station_id,
      'short_count_volume' AS table_name
    FROM highway_data_services.short_count_volume
;

CREATE INDEX regions_to_stations_idx ON highway_data_services.regions_to_stations (region, station_id);

CLUSTER highway_data_services.regions_to_stations USING regions_to_stations_idx;

-- https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_SC%20Formats.pdf
COMMENT ON MATERIALIZED VIEW highway_data_services.regions_to_stations IS
'View that collects, for fast lookups, the station_ids for regions and the count type tables they occur in.';

COMMIT;

ANALYZE highway_data_services.regions_to_stations;
