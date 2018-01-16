CREATE TABLE "__STATE__".top_level_freight_reliability (
  CONSTRAINT state_check CHECK (
    (states = ARRAY['__STATE__']::VARCHAR(2)[])
    OR
    (ARRAY_LENGTH(states, 1) > 1)
  )
) INHERITS (public.top_level_freight_reliability);
