CREATE TABLE public.pm3_eav_append_only (
  pm3meacalc_id  INTEGER REFERENCES pm3_measure_calculator_metadata ON DELETE CASCADE NOT NULL,
  tmc            VARCHAR NOT NULL,
  attribute      VARCHAR NOT NULL,
  value          JSONB
);

CREATE INDEX pm3_eav_append_only_idx ON pm3_eav_append_only (tmc);
