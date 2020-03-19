BEGIN;

CREATE SCHEMA IF NOT EXISTS pm3;

CREATE TABLE IF NOT EXISTS pm3.pm3_measure_calculator_output (
    pm3meacalc_id  INTEGER REFERENCES pm3.pm3_measure_calculator_metadata ON DELETE CASCADE NOT NULL,
    tmc            VARCHAR(9),
    measure_data   JSONB
  ) PARTITION BY LIST (pm3meacalc_id)
;

COMMIT;
