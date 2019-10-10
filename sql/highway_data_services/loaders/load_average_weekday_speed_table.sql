-- psql -f <(sed 's/__REGION__/01/g; s/__YEAR__/2010/g; s#__CSV_GZ_PATH__#/home/paul/AVAIL/NPMRDS_Database/src/highwayDataServicesScrapers/data/average_weekday_speed_R01_2010.csv.gz#g;' sql/highway_data_services/loaders/load_average_weekday_speed_table.sql)

BEGIN;

CREATE SCHEMA IF NOT EXISTS highway_data_services_data;

CREATE TABLE IF NOT EXISTS highway_data_services_data.average_weekday_speed ()
  INHERITS (highway_data_services.average_weekday_speed)
  WITH (fillfactor=100, autovacuum_enabled=false);

DROP TABLE IF EXISTS highway_data_services_data.average_weekday_speed_r__REGION_____YEAR__;

CREATE TABLE highway_data_services_data.average_weekday_speed_r__REGION_____YEAR__ (
  CHECK (rg = '__REGION__'),
  CHECK (year = __YEAR__)
) INHERITS (highway_data_services_data.average_weekday_speed)
WITH (fillfactor=100, autovacuum_enabled=false);

\copy highway_data_services_data.average_weekday_speed_r__REGION_____YEAR__ (rc_station, count_id, rg, region_code, county_code, stat, rcsta, functional_class, factor_group, latitude, longitude, specific_recorder_placement, channel_notes, data_type, speed_limit, year, month, day_of_first_data, federal_direction, full_count, avg_wkday_bin_1, avg_wkday_bin_2, avg_wkday_bin_3, avg_wkday_bin_4, avg_wkday_bin_5, avg_wkday_bin_6, avg_wkday_bin_7, avg_wkday_bin_8, avg_wkday_bin_9, avg_wkday_bin_10, avg_wkday_bin_11, avg_wkday_bin_12, avg_wkday_bin_13, avg_wkday_bin_14, avg_wkday_bin_15, avg_wkday_unclassified, avg_wkday_totals, avg_speed, fiftyth_percentile_speed, eightyfiveth_percentile_speed, percentile_exceeding_55, percentile_exceeding_65, flag_field, batch_id) FROM PROGRAM 'zcat __CSV_GZ_PATH__' WITH DELIMITER ',' CSV HEADER FREEZE; 

COMMIT;
