CREATE TABLE public.pm3_calculator_metadata (
  id          SERIAL PRIMARY KEY,
  metadata    JSONB,
  CHECK (
    ( jsonb_typeof(metadata)='object' )
    AND
    ( metadata->'timestamp' IS NOT NULL )
    AND
    ( jsonb_typeof(metadata->'timestamp') = 'string'  )
  )
);

CREATE UNIQUE INDEX pm3_calculator_metadata_idx
  ON pm3_calculator_metadata( (metadata->'timestamp') )
;
