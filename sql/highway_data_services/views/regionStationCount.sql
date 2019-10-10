BEGIN;

DROP MATERIALIZED VIEW IF EXISTS highway_data_services.region_stations_count;

CREATE MATERIALIZED VIEW IF NOT EXISTS highway_data_services.region_stations_count
WITH (fillfactor = 100)
AS
  SELECT 
    rg AS region,
    COUNT(DISTINCT station_id) AS stations_count,
    count_type
    FROM (
      SELECT
          rg::SMALLINT,
          rc_station AS station_id,
          'SHORT_COUNT' AS count_type
        FROM highway_data_services.short_count_speed
      UNION
      SELECT
          rg::SMALLINT,
          rc_station AS station_id,
          'SHORT_COUNT' AS count_type
        FROM highway_data_services.short_count_vehicle_classification
      UNION
      SELECT
          rg::SMALLINT,
          rc_station AS station_id,
          'SHORT_COUNT' AS count_type
        FROM highway_data_services.short_count_volume
      UNION
      SELECT
          rg::SMALLINT,
          rc_station AS station_id,
          'AVERAGE_WEEKDAY' AS count_type
        FROM highway_data_services.average_weekday_speed
      UNION
      SELECT
          rg::SMALLINT,
          rc_station AS station_id,
          'AVERAGE_WEEKDAY' AS count_type
        FROM highway_data_services.average_weekday_vehicle_classification
      UNION
      SELECT
          rg::SMALLINT,
          rc_station AS station_id,
          'AVERAGE_WEEKDAY' AS count_type
        FROM highway_data_services.average_weekday_volume
      UNION
      SELECT
          region::SMALLINT,
          rc || '_' || station AS station_id,
          'CONTINUOUS' AS count_type
        FROM highway_data_services.continuous_vehicle_classification
      UNION
      SELECT
          region::SMALLINT,
          rc || '_' || station AS station_id,
          'CONTINUOUS' AS count_type
        FROM highway_data_services.continuous_volume
    ) AS t
    GROUP BY rg, count_type
;

CREATE INDEX region_stations_count_idx ON highway_data_services.region_stations_count (region);

CLUSTER highway_data_services.region_stations_count USING region_stations_count_idx;

COMMIT;

ANALYZE highway_data_services.region_stations_count;
