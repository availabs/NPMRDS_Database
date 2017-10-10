CREATE TABLE "__STATE__".top_level_freight_reliability (
  CONSTRAINT state_check CHECK(state = '__STATE__')
) INHERITS (public.top_level_freight_reliability);
