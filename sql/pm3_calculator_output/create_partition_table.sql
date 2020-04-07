\set tbl_name pm3_calculator_output_partitions.pm3_calculator_output_:PM3CALC_ID

BEGIN;

CREATE SCHEMA IF NOT EXISTS pm3_calculator_output_partitions;

CREATE TABLE IF NOT EXISTS :tbl_name
  PARTITION OF pm3.pm3_calculator_output
  FOR VALUES IN (:PM3CALC_ID)
  WITH (fillfactor=100)
;

ALTER TABLE :tbl_name
  ALTER COLUMN pm3calc_id
  SET NOT NULL
;

ALTER TABLE :tbl_name
  ALTER COLUMN pm3calc_id
  SET DEFAULT :PM3CALC_ID
;

COMMIT;
