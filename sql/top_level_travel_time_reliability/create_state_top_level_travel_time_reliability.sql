CREATE TABLE "__STATE__".top_level_travel_time_reliability (
  CONSTRAINT state_check CHECK (
    (states = ARRAY['__STATE__']::VARCHAR(2)[])
    OR
    (ARRAY_LENGTH(states, 1) > 1)
  )
) INHERITS (top_level_travel_time_reliability);
