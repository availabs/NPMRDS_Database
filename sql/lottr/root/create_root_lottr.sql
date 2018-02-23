CREATE TABLE public.lottr (
    tmc            VARCHAR(9),
    state          VARCHAR(2),
    year           SMALLINT,
    month          SMALLINT,
    lottr_am_peak  REAL,
    lottr_midday   REAL,
    lottr_pm_peak  REAL,
    lottr_weekend  REAL,
    lottr_max      REAL
  ) 
  WITH (fillfactor=100, autovacuum_enabled=false)
;
