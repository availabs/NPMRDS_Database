CREATE TABLE "__STATE__".tttr_percentiles (
  CONSTRAINT state_check CHECK(state = '__STATE__')
) INHERITS (public.tttr_percentiles);
