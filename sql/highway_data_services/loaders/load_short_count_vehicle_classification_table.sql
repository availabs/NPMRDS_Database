BEGIN;

CREATE SCHEMA IF NOT EXISTS highway_data_services_data;

CREATE TABLE IF NOT EXISTS highway_data_services_data.short_count_vehicle_classification ()
  INHERITS (highway_data_services.short_count_vehicle_classification)
  WITH (fillfactor=100, autovacuum_enabled=false);

DROP TABLE IF EXISTS highway_data_services_data.short_count_vehicle_classification_r__REGION_____YEAR__;

CREATE TABLE highway_data_services_data.short_count_vehicle_classification_r__REGION_____YEAR__ (
  CHECK (rg = '__REGION__'),
  CHECK (year = __YEAR__)
) INHERITS(highway_data_services_data.short_count_vehicle_classification)
WITH (fillfactor=100, autovacuum_enabled=false);

\copy highway_data_services_data.short_count_vehicle_classification_r__REGION_____YEAR__ (rc_station, count_id, rg, region_code, county_code, stat, rcsta, functional_class, factor_group, latitude, longitude, specific_recorder_placement, channel_notes, data_type, blank, year, month, day, day_of_week, federal_direction, lane_code, lanes_in_direction, collection_interval, data_interval, class_f1, class_f2, class_f3, class_f4, class_f5, class_f6, class_f7, class_f8, class_f9, class_f10, class_f11, class_f12, class_f13, unclassified, total, flag_field, batch_id) FROM PROGRAM 'zcat __CSV_GZ_PATH__' WITH DELIMITER ',' CSV HEADER FREEZE;

COMMIT;
