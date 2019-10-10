BEGIN;

CREATE SCHEMA IF NOT EXISTS highway_data_services_data;

CREATE TABLE IF NOT EXISTS highway_data_services_data.continuous_vehicle_classification ()
  INHERITS (highway_data_services.continuous_vehicle_classification)
  WITH (fillfactor=100, autovacuum_enabled=false);

DROP TABLE IF EXISTS highway_data_services_data.continuous_vehicle_classification_r__REGION_____YEAR__;

CREATE TABLE highway_data_services_data.continuous_vehicle_classification_r__REGION_____YEAR__ (
  CHECK (region = '__REGION__'),
  CHECK (year = __YEAR__)
) INHERITS (highway_data_services_data.continuous_vehicle_classification)
  WITH (fillfactor=100, autovacuum_enabled=false);

\copy highway_data_services_data.continuous_vehicle_classification_r__REGION_____YEAR__ (rc, station, region, dotid, ccid, fc, route, roadname, county, county_fips, begin_desc, end_desc, station_id, road, one_way, year, month, day, dow, hour, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13) FROM PROGRAM 'zcat __CSV_GZ_PATH__' WITH DELIMITER ',' CSV HEADER FREEZE;

COMMIT;
