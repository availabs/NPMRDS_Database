CREATE TABLE top_level_total_excessive_delay (
  state                        VARCHAR(2),
  year                         SMALLINT,
  month                        SMALLINT,
  geography_level              geography_level_type,
  geography_name               VARCHAR,
  functional_class             functional_class_type,
  am_peak_total_xdelay_hrs     DOUBLE PRECISION,
  pm1_peak_total_xdelay_hrs    DOUBLE PRECISION,
  pm2_peak_total_xdelay_hrs    DOUBLE PRECISION,
  included_mi                  REAL,
  excluded_mi                  REAL,
  included_tmcs_ct             INTEGER,
  excluded_tmcs_ct             INTEGER,
  summary_stats_by_phed_period JSONB
);

