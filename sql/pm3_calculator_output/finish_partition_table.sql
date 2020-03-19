\set tbl_name pm3_calculator_output_partitions.pm3_calculator_output_:PM3MEACALC_ID
\set pkey_idx_name pm3_calculator_output_:PM3MEACALC_ID'_pkey'

BEGIN;

ALTER TABLE :tbl_name
  ADD CONSTRAINT :pkey_idx_name
  PRIMARY KEY (tmc)
;

CLUSTER :tbl_name USING :pkey_idx_name;

COMMIT;
