BEGIN;

CREATE SCHEMA IF NOT EXISTS highway_data_services_data;

CREATE TABLE IF NOT EXISTS highway_data_services_data.short_count_volume ()
  INHERITS (highway_data_services.short_count_volume)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

DROP TABLE IF EXISTS highway_data_services_data.short_count_volume_r__REGION_____YEAR__;

CREATE TABLE highway_data_services_data.short_count_volume_r__REGION_____YEAR__ (
  CHECK (rg = '__REGION__'),
  CHECK (year = __YEAR__)
) INHERITS(highway_data_services_data.short_count_volume)
  WITH (fillfactor=100, autovacuum_enabled=false);

\copy highway_data_services_data.short_count_volume_r__REGION_____YEAR__ (rc_station, count_id, rg, region_code, county_code, stat, rcsta, functional_class, factor_group, latitude, longitude, specific_recorder_placement, channel_notes, data_type, vehicle_axle_code, year, month, day, day_of_week, federal_direction, lane_code, lanes_in_direction, collection_interval, interval_1_1, interval_1_2, interval_1_3, interval_1_4, interval_2_1, interval_2_2, interval_2_3, interval_2_4, interval_3_1, interval_3_2, interval_3_3, interval_3_4, interval_4_1, interval_4_2, interval_4_3, interval_4_4, interval_5_1, interval_5_2, interval_5_3, interval_5_4, interval_6_1, interval_6_2, interval_6_3, interval_6_4, interval_7_1, interval_7_2, interval_7_3, interval_7_4, interval_8_1, interval_8_2, interval_8_3, interval_8_4, interval_9_1, interval_9_2, interval_9_3, interval_9_4, interval_10_1, interval_10_2, interval_10_3, interval_10_4, interval_11_1, interval_11_2, interval_11_3, interval_11_4, interval_12_1, interval_12_2, interval_12_3, interval_12_4, interval_13_1, interval_13_2, interval_13_3, interval_13_4, interval_14_1, interval_14_2, interval_14_3, interval_14_4, interval_15_1, interval_15_2, interval_15_3, interval_15_4, interval_16_1, interval_16_2, interval_16_3, interval_16_4, interval_17_1, interval_17_2, interval_17_3, interval_17_4, interval_18_1, interval_18_2, interval_18_3, interval_18_4, interval_19_1, interval_19_2, interval_19_3, interval_19_4, interval_20_1, interval_20_2, interval_20_3, interval_20_4, interval_21_1, interval_21_2, interval_21_3, interval_21_4, interval_22_1, interval_22_2, interval_22_3, interval_22_4, interval_23_1, interval_23_2, interval_23_3, interval_23_4, interval_24_1, interval_24_2, interval_24_3, interval_24_4, total, flag_field, batch_id) FROM PROGRAM 'zcat __CSV_GZ_PATH__' WITH DELIMITER ',' CSV HEADER FREEZE;

COMMIT;
