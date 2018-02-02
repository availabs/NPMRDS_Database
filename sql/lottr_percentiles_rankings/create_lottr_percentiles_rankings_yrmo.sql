BEGIN;

CREATE TABLE IF NOT EXISTS interstate.lottr_percentiles_rankings_y__YEAR__m__MONTH__ ( 
    LIKE lottr_percentiles_rankings INCLUDING ALL,
    CONSTRAINT lottr_percentiles_rankings_y__YEAR__m__MONTH___pkey PRIMARY KEY (tmc),
    CONSTRAINT lottr_percentiles_rankings_yr_check CHECK (year = __YEAR__),
    CONSTRAINT lottr_percentiles_rankings_mo_check CHECK (month = __MONTH__)
  )
  INHERITS (public.lottr_percentiles_rankings)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

COMMIT;
