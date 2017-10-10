DROP TABLE IF EXISTS "__STATE__".top_level_freight_reliability CASCADE;

CREATE TABLE "__STATE__".top_level_freight_reliability (
  LIKE top_level_freight_reliability
);

ALTER TABLE "__STATE__".top_level_freight_reliability
  ADD CONSTRAINT state_check CHECK(state = '__STATE__'),
  INHERIT top_level_freight_reliability;
