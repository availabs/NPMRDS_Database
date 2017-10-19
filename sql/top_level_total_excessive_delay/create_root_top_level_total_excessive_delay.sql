CREATE TABLE top_level_total_excessive_delay (
  state                       VARCHAR(2),
  year                        SMALLINT,
  month                       SMALLINT,
  geography_level             geography_level_type,
  geography_name              VARCHAR,
  functional_class            functional_class_type,
  included_mi                 REAL,
  excluded_mi                 REAL,
  included_tmcs_ct            INTEGER,
  excluded_tmcs_ct            INTEGER,
  xdelay_per_mile_quartiles   DOUBLE PRECISION[5],
  xdelay_per_mile_mean        DOUBLE PRECISION,
  xdelay_per_mile_stddev      DOUBLE PRECISION,
  total_excessive_delay       DOUBLE PRECISION
);

