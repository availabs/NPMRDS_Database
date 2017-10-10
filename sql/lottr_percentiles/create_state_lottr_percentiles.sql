CREATE TABLE "__STATE__".lottr_percentiles (
  CONSTRAINT state_check CHECK(state = '__STATE__')
) INHERITS (lottr_percentiles);
