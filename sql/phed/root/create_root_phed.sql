CREATE TABLE public.phed (
    tmc             VARCHAR(9),
    state           VARCHAR(2),
    year            SMALLINT,
    month           SMALLINT,
    phed_am_peak    DOUBLE PRECISION,
    phed_pm_peak_1  DOUBLE PRECISION,
    phed_pm_peak_2  DOUBLE PRECISION,
    phed_max        DOUBLE PRECISION
  )
  WITH (fillfactor=100, autovacuum_enabled=false)
;
