\set tbl_name pm3_calculator_output_partitions.pm3_calculator_output_:PM3MEACALC_ID
\set idx_name pm3_calculator_output_:PM3MEACALC_ID'_pkey'

BEGIN;

CREATE SCHEMA IF NOT EXISTS pm3_calculator_output_partitions;

CREATE TABLE :tbl_name
  PARTITION OF pm3.pm3_calculator_output
  FOR VALUES IN (:PM3MEACALC_ID)
  WITH (fillfactor=100)
;

ALTER TABLE :tbl_name
  ALTER COLUMN pm3meacalc_id
  SET NOT NULL
;

ALTER TABLE :tbl_name
  ALTER COLUMN pm3meacalc_id
  SET DEFAULT :PM3MEACALC_ID
;

COMMIT;
