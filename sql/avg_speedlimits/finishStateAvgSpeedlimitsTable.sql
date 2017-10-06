BEGIN;

ALTER TABLE "__STATE__".avg_speedlimits
  ALTER COLUMN state SET DEFAULT '__STATE__',
  ADD CONSTRAINT avg_speedlimits_pkey PRIMARY KEY (tmc),
  ADD CONSTRAINT avg_speedlimits_state_check CHECK(state = '__STATE__'),
  INHERIT public.avg_speedlimits;

CLUSTER VERBOSE "__STATE__".avg_speedlimits 
  USING avg_speedlimits_pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".avg_speedlimits;
