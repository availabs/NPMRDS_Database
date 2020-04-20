BEGIN;

CREATE TABLE highway_data_services.raw_continuous_volume (
    region               TEXT,
    region_code          SMALLINT,
    county_code          SMALLINT,
    station              TEXT,
    rcsta                TEXT,
    functional_class     SMALLINT,
    factor_group         SMALLINT,
    year                 SMALLINT,
    month                SMALLINT,
    day                  SMALLINT,
    day_of_week          TEXT,
    federal_direction    SMALLINT,
    lane_code            SMALLINT,
    lanes_in_direction   SMALLINT,
    interval_01          INTEGER,
    interval_02          INTEGER,
    interval_03          INTEGER,
    interval_04          INTEGER,
    interval_05          INTEGER,
    interval_06          INTEGER,
    interval_07          INTEGER,
    interval_08          INTEGER,
    interval_09          INTEGER,
    interval_10          INTEGER,
    interval_11          INTEGER,
    interval_12          INTEGER,
    interval_13          INTEGER,
    interval_14          INTEGER,
    interval_15          INTEGER,
    interval_16          INTEGER,
    interval_17          INTEGER,
    interval_18          INTEGER,
    interval_19          INTEGER,
    interval_20          INTEGER,
    interval_21          INTEGER,
    interval_22          INTEGER,
    interval_23          INTEGER,
    interval_24          INTEGER,
    total_count          INTEGER,

    PRIMARY KEY (rcsta, year, month, day, federal_direction, lane_code)
) WITH(fillfactor=100);

CLUSTER highway_data_services.raw_continuous_volume
  USING raw_continuous_volume_pkey
;

COMMIT;
