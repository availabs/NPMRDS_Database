BEGIN;

DROP MATERIALIZED VIEW IF EXISTS highway_data_services.region_counts_per_year;

CREATE MATERIALIZED VIEW IF NOT EXISTS highway_data_services.region_counts_per_year
WITH (fillfactor = 100)
AS
  SELECT
      rg::SMALLINT AS region,
      year,
      'SHORT_COUNT_SPEED' AS count_type,
      COUNT(DISTINCT count_id) AS total_counts
    FROM highway_data_services.short_count_speed
    GROUP BY rg, year
  UNION
  SELECT
      rg::SMALLINT AS region,
      year,
      'SHORT_COUNT_VEHICLE_CLASSIFICATION' AS count_type,
      COUNT(DISTINCT count_id) AS total_counts
    FROM highway_data_services.short_count_vehicle_classification
    GROUP BY rg, year
  UNION
  SELECT
      rg::SMALLINT AS region,
      year,
      'SHORT_COUNT_VOLUME' AS count_type,
      COUNT(DISTINCT count_id) AS total_counts
    FROM highway_data_services.short_count_volume
    GROUP BY rg, year
  UNION
  SELECT
      rg::SMALLINT AS region,
      year,
      'AVERAGE_WEEKDAY_SPEED' AS count_type,
      COUNT(DISTINCT count_id) AS total_counts
    FROM highway_data_services.average_weekday_speed
    GROUP BY rg, year
  UNION
  SELECT
      rg::SMALLINT AS region,
      year,
      'AVERAGE_WEEKDAY_VEHICLE_CLASSIFICATION' AS count_type,
      COUNT(DISTINCT count_id) AS total_counts
    FROM highway_data_services.average_weekday_vehicle_classification
    GROUP BY rg, year
  UNION
  SELECT
      rg::SMALLINT AS region,
      year,
      'AVERAGE_WEEKDAY_VOLUME' AS count_type,
      COUNT(DISTINCT count_id) AS total_counts
    FROM highway_data_services.average_weekday_volume
    GROUP BY rg, year
  UNION
  SELECT
      region::SMALLINT,
      year,
      'COUNTINUOUS_VEHICLE_CLASSIFICATION' AS count_type,
      COUNT(1) AS total_counts
    FROM highway_data_services.continuous_vehicle_classification
    GROUP BY region, year
  UNION
  SELECT
      region::SMALLINT,
      year,
      'CONTINUOUS_VOLUME' AS count_type,
      COUNT(1) AS total_counts
    FROM highway_data_services.continuous_volume
    GROUP BY region, year
  ;


CREATE INDEX region_counts_per_year_idx ON highway_data_services.region_counts_per_year (region);

CLUSTER highway_data_services.region_counts_per_year USING region_counts_per_year_idx;

COMMIT;

ANALYZE highway_data_services.region_counts_per_year;
