BEGIN;

CREATE SCHEMA IF NOT EXISTS pm3;

CREATE TABLE IF NOT EXISTS pm3.pm3_calculator_output (
    pm3calc_id     INTEGER REFERENCES pm3.pm3_calculator_metadata ON DELETE CASCADE NOT NULL,
    tmc            VARCHAR(9),
    measure        TEXT,
    measure_data   JSONB
  ) PARTITION BY LIST (pm3calc_id)
;

COMMIT;
