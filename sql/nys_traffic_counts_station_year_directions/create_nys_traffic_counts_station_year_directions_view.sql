BEGIN;

CREATE OR REPLACE VIEW conflation.nys_traffic_counts_station_year_directions
  AS
    SELECT
        rc_station,
        year,
        federal_direction
      FROM highway_data_services.average_weekday_speed
      WHERE ( federal_direction IN (1, 3, 5, 7) )
    UNION
    SELECT
        rc_station,
        year,
        federal_direction
      FROM highway_data_services.average_weekday_vehicle_classification
      WHERE ( federal_direction IN (1, 3, 5, 7) )
    UNION
    SELECT
        rc_station,
        year,
        federal_direction
      FROM highway_data_services.average_weekday_volume
      WHERE ( federal_direction IN (1, 3, 5, 7) )
    UNION
    SELECT
        rc_station,
        year,
        federal_direction
      FROM highway_data_services.short_count_speed
      WHERE ( federal_direction IN (1, 3, 5, 7) )
    UNION
    SELECT
        rc_station,
        year,
        federal_direction
      FROM highway_data_services.short_count_vehicle_classification
      WHERE ( federal_direction IN (1, 3, 5, 7) )
    UNION
    SELECT
        rc_station,
        year,
        federal_direction
      FROM highway_data_services.short_count_volume
      WHERE ( federal_direction IN (1, 3, 5, 7) )
;

COMMIT;
