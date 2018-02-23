CREATE TABLE public.phed (
    tmc             VARCHAR(9),
    state           VARCHAR(2),
    year            SMALLINT,
    month           SMALLINT,
    phed_am_peak    REAL,
    phed_pm1_peak   REAL,
    phed_pm2_peak   REAL,
    phed_max        REAL
  )
  WITH (fillfactor=100, autovacuum_enabled=false)
;
