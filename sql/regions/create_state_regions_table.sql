CREATE TABLE "__STATE__".regions (
  CONSTRAINT regions_state_pk PRIMARY KEY (id),
  CONSTRAINT regions_state_check CHECK(state = '__STATE__')
) INHERITS (public.regions) WITH (fillfactor=100, autovacuum_enabled=false);
