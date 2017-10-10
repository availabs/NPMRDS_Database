CREATE TABLE "__STATE__".top_level_travel_time_reliability (
  CONSTRAINT state_check CHECK(state = '__STATE__')
) INHERITS (top_level_travel_time_reliability);
