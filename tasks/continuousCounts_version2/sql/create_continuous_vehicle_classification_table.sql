BEGIN;

DROP TABLE IF EXISTS highway_data_services.raw_continuous_vehicle_classification;

CREATE TABLE IF NOT EXISTS highway_data_services.raw_continuous_vehicle_classification (
  count_id                     TEXT,
  region                       TEXT,
  region_code                  SMALLINT,
  county_code                  SMALLINT,
  station                      TEXT,
  rcsta                        TEXT,
  functional_class             SMALLINT,
  factor_group                 SMALLINT,
  latitude                     DOUBLE PRECISION,
  longitude                    DOUBLE PRECISION,
  specific_recorder_placement  TEXT,
  channel_notes                TEXT,
  data_type                    TEXT,
  blank                        TEXT,
  year                         SMALLINT,
  month                        SMALLINT,
  day                          SMALLINT,
  day_of_week                  TEXT,
  federal_direction            SMALLINT,
  lane_code                    SMALLINT,
  lanes_in_direction           SMALLINT,
  collection_interval          SMALLINT,
  data_interval                DOUBLE PRECISION,
  class_f1                     INTEGER,
  class_f2                     INTEGER,
  class_f3                     INTEGER,
  class_f4                     INTEGER,
  class_f5                     INTEGER,
  class_f6                     INTEGER,
  class_f7                     INTEGER,
  class_f8                     INTEGER,
  class_f9                     INTEGER,
  class_f10                    INTEGER,
  class_f11                    INTEGER,
  class_f12                    INTEGER,
  class_f13                    INTEGER,
  unclassified                 INTEGER,
  total                        INTEGER,
  flag_field                   TEXT,
  batch_id                     INTEGER,

  PRIMARY KEY (
    rcsta,
    year,
    month,
    day,
    federal_direction,
    lane_code,
    data_interval,
    batch_id
  )
) WITH(fillfactor=100);

CLUSTER highway_data_services.raw_continuous_vehicle_classification
  USING raw_continuous_vehicle_classification_pkey
;

COMMIT;
