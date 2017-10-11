CREATE TABLE "__STATE__".region_to_county (
  CONSTRAINT region_to_county_state_check CHECK(state = '__STATE__'),
  CONSTRAINT region_to_county_pk PRIMARY KEY (county, state),
  CONSTRAINT region_to_county_fk FOREIGN KEY (region_id) REFERENCES "__STATE__".regions (id)
) INHERITS (public.region_to_county) WITH (fillfactor=100, autovacuum_enabled=false);
