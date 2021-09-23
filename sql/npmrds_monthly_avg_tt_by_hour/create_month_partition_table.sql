\set yr_tbl_name 'npmrds_monthly_avg_tt_by_hour_partitions.npmrds_monthly_avg_tt_by_hour_y':YEAR
\set yrmo_tbl_name 'npmrds_monthly_avg_tt_by_hour_partitions.npmrds_monthly_avg_tt_by_hour_y':YEAR'm':MONTH

BEGIN;

CREATE SCHEMA IF NOT EXISTS npmrds_monthly_avg_tt_by_hour_partitions;

CREATE TABLE IF NOT EXISTS :yr_tbl_name
  PARTITION OF public.npmrds_monthly_avg_tt_by_hour
    FOR VALUES IN (:YEAR)
  PARTITION BY LIST (month)
;

CREATE TABLE IF NOT EXISTS :yrmo_tbl_name
  PARTITION OF :yr_tbl_name
    FOR VALUES IN (:MONTH)
  PARTITION BY LIST (state)
;

COMMIT;
