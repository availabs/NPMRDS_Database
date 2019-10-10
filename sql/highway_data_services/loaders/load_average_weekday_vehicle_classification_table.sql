BEGIN;

CREATE SCHEMA IF NOT EXISTS highway_data_services_data;

CREATE TABLE IF NOT EXISTS highway_data_services_data.average_weekday_vehicle_classification ()
  INHERITS (highway_data_services.average_weekday_vehicle_classification)
  WITH (fillfactor=100, autovacuum_enabled=false);

DROP TABLE IF EXISTS highway_data_services_data.average_weekday_vehicle_classification_r__REGION_____YEAR__;

CREATE TABLE highway_data_services_data.average_weekday_vehicle_classification_r__REGION_____YEAR__ (
  CHECK (rg = '__REGION__'),
  CHECK (year = __YEAR__)
) INHERITS(highway_data_services_data.average_weekday_vehicle_classification)
WITH (fillfactor=100, autovacuum_enabled=false);

\copy highway_data_services_data.average_weekday_vehicle_classification_r__REGION_____YEAR__ (rc_station, count_id, rg, region_code, county_code, stat, rcsta, functional_class, factor_group, latitude, longitude, specific_recorder_placement, channel_notes, data_type, blank, year, month, day_of_first_data, federal_direction, full_count, avg_wkday_f1s, avg_wkday_f2s, avg_wkday_f3s, avg_wkday_f4s, avg_wkday_f5s, avg_wkday_f6s, avg_wkday_f7s, avg_wkday_f8s, avg_wkday_f9s, avg_wkday_f10s, avg_wkday_f11s, avg_wkday_f12s, avg_wkday_f13s, avg_wkday_unclassified, avg_wkday_totals, avg_wkday_perc_f3_13, avg_wkday_perc_f4_13, avg_wkday_perc_f4_7, avg_wkday_perc_f8_13, avg_wkday_perc_f1, avg_wkday_perc_f2, avg_wkday_perc_f3, avg_wkday_perc_f4, avg_wkday_perc_f5_7, axle_correction_factor, su_peak, cu_peak, su_aadt, cu_aadt, flag_field, batch_id) FROM PROGRAM 'zcat __CSV_GZ_PATH__' WITH DELIMITER ',' CSV HEADER FREEZE; 

COMMIT;
