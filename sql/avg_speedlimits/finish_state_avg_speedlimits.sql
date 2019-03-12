ALTER TABLE :"STATE".avg_speedlimits
  ALTER COLUMN state SET DEFAULT :'STATE',
  ADD CONSTRAINT avg_speedlimits_pkey PRIMARY KEY (tmc),
  ADD CONSTRAINT avg_speedlimits_state_check CHECK(state = :'STATE'),
  INHERIT public.avg_speedlimits;

CLUSTER VERBOSE :"STATE".avg_speedlimits 
  USING avg_speedlimits_pkey;
