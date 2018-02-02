BEGIN;

CREATE TABLE IF NOT EXISTS interstate.excessive_delay_rankings_y__YEAR__m__MONTH__ ( 
    LIKE excessive_delay_rankings INCLUDING ALL,
    CONSTRAINT excessive_delay_rankings_y__YEAR__m__MONTH___pkey PRIMARY KEY (tmc),
    CONSTRAINT excessive_delay_rankings_yr_check CHECK (year = __YEAR__),
    CONSTRAINT excessive_delay_rankings_mo_check CHECK (month = __MONTH__)
  )
  INHERITS (public.excessive_delay_rankings)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
