CREATE TABLE public.tttr (
    tmc             VARCHAR(9),
    state           VARCHAR(2),
    year            SMALLINT,
    month           SMALLINT,
    tttr_am_peak    REAL,
    tttr_midday     REAL,
    tttr_pm_peak    REAL,
    tttr_weekend    REAL,
    tttr_overnight  REAL,
    tttr_max        REAL
  ) WITH (fillfactor=100, autovacuum_enabled=false)
;
