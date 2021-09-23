BEGIN;

CREATE TABLE IF NOT EXISTS public.npmrds_monthly_avg_tt_by_hour (
    tmc            VARCHAR(9) NOT NULL,
    year           SMALLINT NOT NULL,
    month          SMALLINT NOT NULL,
    hour           SMALLINT NOT NULL,
    avg_tt         REAL NOT NULL,
    state          VARCHAR(2) NOT NULL
) PARTITION BY LIST (year) ;

COMMIT;
