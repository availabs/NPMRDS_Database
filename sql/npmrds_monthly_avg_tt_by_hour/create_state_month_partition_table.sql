-- Requires STATE, YEAR, MONTH

\set parent_tbl_name 'npmrds_monthly_avg_tt_by_hour_partitions.npmrds_monthly_avg_tt_by_hour_y':YEAR'm':MONTH
\set npmrds_tbl_name :"STATE"'.npmrds_y':YEAR'm':MONTH
\set tbl_name :"STATE"'.npmrds_monthly_avg_tt_by_hour_y':YEAR'm':MONTH
\set pkey_idx_name 'npmrds_monthly_avg_tt_by_hour_y':YEAR'm':MONTH'_pkey'
\set fkey_constraint_name 'npmrds_monthly_avg_tt_by_hour_y':YEAR'm':MONTH'_fkey'

BEGIN;

CREATE SCHEMA IF NOT EXISTS :"STATE";

CREATE TABLE IF NOT EXISTS :tbl_name
  PARTITION OF :parent_tbl_name
    FOR VALUES IN (:'STATE')
  WITH (fillfactor=100, autovacuum_enabled=false)
;

ALTER TABLE :tbl_name
  ALTER COLUMN year
    SET DEFAULT :YEAR
;

ALTER TABLE :tbl_name
  ALTER COLUMN month
    SET DEFAULT :MONTH
;

ALTER TABLE :tbl_name
  ALTER COLUMN state
    SET DEFAULT :'STATE'
;

ALTER TABLE :tbl_name
  ADD CONSTRAINT :pkey_idx_name
    PRIMARY KEY (tmc, hour)
;

CLUSTER :tbl_name USING :pkey_idx_name;

COMMIT;
