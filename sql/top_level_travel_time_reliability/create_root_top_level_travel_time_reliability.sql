CREATE TABLE top_level_travel_time_reliability (
  states            VARCHAR(2)[],
  year              SMALLINT,
  month             SMALLINT,
  geography_level   geography_level_type,
  geography_name    VARCHAR,
  functional_class  functional_class_type,
  included_mi       REAL,
  passing_mi        REAL,
  excluded_mi       REAL,
  included_tmcs_ct  INTEGER,
  excluded_tmcs_ct  INTEGER,
  lottr_quartiles   REAL[5],
  lottr_mean        REAL,
  lottr_stddev      REAL,
  ttr               REAL
);

