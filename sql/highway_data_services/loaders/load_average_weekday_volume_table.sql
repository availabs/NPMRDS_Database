BEGIN;

CREATE SCHEMA IF NOT EXISTS highway_data_services_data;

CREATE TABLE IF NOT EXISTS highway_data_services_data.average_weekday_volume ()
  INHERITS (highway_data_services.average_weekday_volume)
  WITH (fillfactor=100, autovacuum_enabled=false);

DROP TABLE IF EXISTS highway_data_services_data.average_weekday_volume_r__REGION_____YEAR__;

CREATE TABLE highway_data_services_data.average_weekday_volume_r__REGION_____YEAR__ (
  CHECK (rg = '__REGION__'),
  CHECK (year = __YEAR__)
) INHERITS (highway_data_services_data.average_weekday_volume)
  WITH (fillfactor=100, autovacuum_enabled=false);

\copy highway_data_services_data.average_weekday_volume_r__REGION_____YEAR__ (rc_station, count_id, rg, region_code, county_code, stat, rcsta, functional_class, factor_group, latitude, longitude, specific_recorder_placement, channel_notes, data_type, vehicle_axle_code, year, month, day_of_first_data, federal_direction, full_count, avg_wkday_interval_1, avg_wkday_interval_2, avg_wkday_interval_3, avg_wkday_interval_4, avg_wkday_interval_5, avg_wkday_interval_6, avg_wkday_interval_7, avg_wkday_interval_8, avg_wkday_interval_9, avg_wkday_interval_10, avg_wkday_interval_11, avg_wkday_interval_12, avg_wkday_interval_13, avg_wkday_interval_14, avg_wkday_interval_15, avg_wkday_interval_16, avg_wkday_interval_17, avg_wkday_interval_18, avg_wkday_interval_19, avg_wkday_interval_20, avg_wkday_interval_21, avg_wkday_interval_22, avg_wkday_interval_23, avg_wkday_interval_24, avg_wkday_daily_traffic, seasonal_factor, axle_factor, aadt, high_hour_value, high_hour_interval, k_factor, d_factor, flag_field, batch_id) FROM PROGRAM 'zcat __CSV_GZ_PATH__' WITH (DELIMITER ',', FORMAT CSV, HEADER, FORCE_NULL(latitude, longitude), FREEZE);   

COMMIT;
