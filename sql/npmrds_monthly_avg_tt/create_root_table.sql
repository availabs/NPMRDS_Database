BEGIN;

CREATE TABLE IF NOT EXISTS public.npmrds_monthly_avg_tt (
    tmc            VARCHAR(9) NOT NULL,
    year           SMALLINT NOT NULL,
    month          SMALLINT NOT NULL,
    state          VARCHAR(2) NOT NULL,
    hr_0           REAL,
    hr_1           REAL,
    hr_2           REAL,
    hr_3           REAL,
    hr_4           REAL,
    hr_5           REAL,
    hr_6           REAL,
    hr_7           REAL,
    hr_8           REAL,
    hr_9           REAL,
    hr_10          REAL,
    hr_11          REAL,
    hr_12          REAL,
    hr_13          REAL,
    hr_14          REAL,
    hr_15          REAL,
    hr_16          REAL,
    hr_17          REAL,
    hr_18          REAL,
    hr_19          REAL,
    hr_20          REAL,
    hr_21          REAL,
    hr_22          REAL,
    hr_23          REAL
) PARTITION BY LIST (year) ;

COMMIT;
