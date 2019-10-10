BEGIN;

CREATE SCHEMA IF NOT EXISTS highway_data_services_data;

CREATE TABLE IF NOT EXISTS highway_data_services_data.continuous_volume ()
  INHERITS (highway_data_services.continuous_volume)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

DROP TABLE IF EXISTS highway_data_services_data.continuous_volume_r__REGION_____YEAR__;

CREATE TABLE highway_data_services_data.continuous_volume_r__REGION_____YEAR__ (
  CHECK (region = '__REGION__'),
  CHECK (year = __YEAR__)
) INHERITS(highway_data_services_data.continuous_volume)
  WITH (fillfactor=100, autovacuum_enabled=false);

\copy highway_data_services_data.continuous_volume_r__REGION_____YEAR__ (rc, station, region, dotid, ccid, fc, route, roadname, county, county_fips, begin_desc, end_desc, station_id, road, one_way, year, month, day, dow, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24) FROM PROGRAM 'zcat __CSV_GZ_PATH__' WITH DELIMITER ',' CSV HEADER FREEZE;

COMMIT;
