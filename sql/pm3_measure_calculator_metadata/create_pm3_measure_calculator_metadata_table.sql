CREATE TABLE public.pm3_measure_calculator_metadata (
  id                 SERIAL PRIMARY KEY,
  pm3calc_id         INTEGER REFERENCES pm3_calculator_metadata ON DELETE CASCADE NOT NULL,
  metadata           JSONB NOT NULL,
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

/* This doesn't allow separate calculator runs per state. 

-- Enforce "authoritativeness" per measure calculator configuration.
-- For each distinct metadata object, only one can be authoritative.
CREATE UNIQUE INDEX pm3_measure_calculator_metadata_uniq
  ON public.pm3_measure_calculator_metadata (metadata)
  WHERE (
    (authoritative_start IS NOT NULL)
    AND
    (authoritative_end IS NULL)
  )
;

*/
