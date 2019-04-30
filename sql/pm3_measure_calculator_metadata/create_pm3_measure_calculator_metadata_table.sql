CREATE TABLE public.pm3_measure_calculator_metadata (
  id                 SERIAL PRIMARY KEY,
  pm3calc_id         INTEGER REFERENCES pm3_calculator_metadata ON DELETE CASCADE NOT NULL,
  metadata           JSONB NOT NULL,
  authorative_start  TIMESTAMP,
  authorative_end    TIMESTAMP,

  -- Check that metadata is an object containing both "measure" and "year" fields
  CHECK (
    jsonb_typeof(metadata)='object'
    AND
    jsonb_typeof(metadata->'measure') = 'string'
    AND
    jsonb_typeof(metadata->'year') = 'number'
  )
);

-- Enforce "authorativeness" per measure calculator configuration.
-- For each distinct metadata object, only one can be authorative.
CREATE UNIQUE INDEX pm3_measure_calculator_metadata_uniq
  ON public.pm3_measure_calculator_metadata (metadata)
  WHERE (
    (authorative_start IS NOT NULL)
    AND
    (authorative_end IS NULL)
  )
;
