CREATE TABLE public.pm3_measure_calculator_metadata (
  id                 SERIAL PRIMARY KEY,
  pm3calc_id         INTEGER REFERENCES pm3_calculator_metadata ON DELETE CASCADE NOT NULL,
  metadata           JSONB NOT NULL,
  authorative_start  TIMESTAMP,
  authorative_end    TIMESTAMP,
  CHECK (
    jsonb_typeof(metadata)='object'
    AND
    metadata->'measure' IS NOT NULL
    AND
    metadata->'year' IS NOT NULL
    AND
    jsonb_typeof(metadata->'year')='number'
  )
);
