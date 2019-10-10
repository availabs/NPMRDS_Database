BEGIN;

CREATE SCHEMA IF NOT EXISTS highway_data_services_data;

CREATE TABLE IF NOT EXISTS highway_data_services_data.short_count_speed ()
  INHERITS (highway_data_services.short_count_speed)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

DROP TABLE IF EXISTS highway_data_services_data.short_count_speed_r__REGION_____YEAR__;

CREATE TABLE highway_data_services_data.short_count_speed_r__REGION_____YEAR__ (
  CHECK (rg = '__REGION__'),
  CHECK (year = __YEAR__)
) INHERITS(highway_data_services_data.short_count_speed)
  WITH (fillfactor=100, autovacuum_enabled=false);

\copy highway_data_services_data.short_count_speed_r__REGION_____YEAR__ (rc_station, count_id, rg, region_code, county_code, stat, rcsta, functional_class, factor_group, latitude, longitude, specific_recorder_placement, channel_notes, data_type, speed_limit, year, month, day, day_of_week, federal_direction, lane_code, lanes_in_direction, collection_interval, data_interval, bin_1, bin_2, bin_3, bin_4, bin_5, bin_6, bin_7, bin_8, bin_9, bin_10, bin_11, bin_12, bin_13, bin_14, bin_15, unclassified, total, flag_field, batch_id) FROM PROGRAM 'zcat __CSV_GZ_PATH__' WITH DELIMITER ',' CSV HEADER FREEZE;

COMMIT;
