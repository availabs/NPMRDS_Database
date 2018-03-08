CREATE TABLE public.phed (
    tmc             VARCHAR(9),
    state           VARCHAR(2),
    year            SMALLINT,
    month           SMALLINT,
    phed_am_peak    REAL,
    phed_pm_peak_1  REAL,
    phed_pm_peak_2  REAL,
    phed_max        REAL
  )
  WITH (fillfactor=100, autovacuum_enabled=false)
;
