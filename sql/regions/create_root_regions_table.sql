CREATE TABLE public.regions (
  id SMALLINT,
  name VARCHAR,
  state  VARCHAR(2)
) WITH (fillfactor=100, autovacuum_enabled=false);
