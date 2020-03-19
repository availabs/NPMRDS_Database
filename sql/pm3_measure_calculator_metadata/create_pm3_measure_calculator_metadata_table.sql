BEGIN;

CREATE TABLE IF NOT EXISTS pm3.pm3_measure_calculator_metadata (
  id                   SERIAL PRIMARY KEY,
  pm3calc_id           INTEGER REFERENCES pm3.pm3_calculator_metadata ON DELETE CASCADE NOT NULL,
  metadata             JSONB NOT NULL,
  authoritative_start  TIMESTAMP,
  authoritative_end    TIMESTAMP,

  -- Check that metadata is an object containing both "measure" and "year" fields
  CHECK (
    ( jsonb_typeof(metadata)='object' )
    AND
    ( metadata->'measure' IS NOT NULL )
    AND
    ( jsonb_typeof(metadata->'measure') = 'string' )
    AND
    ( metadata->'year' IS NOT NULL )
    AND
    ( jsonb_typeof(metadata->'year') = 'number' )
  )
);

COMMIT;
