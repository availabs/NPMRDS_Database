CREATE TABLE public.phed (
    tmc                VARCHAR(9),
    state              VARCHAR(2),
    year               SMALLINT,
    month              SMALLINT,

    xdelay_am_peak     NUMERIC,
    xdelay_pm_peak_1   NUMERIC,
    xdelay_pm_peak_2   NUMERIC,

    phed_am_peak       NUMERIC,
    phed_pm_peak_1     NUMERIC,
    phed_pm_peak_2     NUMERIC,
    phed_max           NUMERIC
  )
  WITH (fillfactor=100, autovacuum_enabled=false)
;
