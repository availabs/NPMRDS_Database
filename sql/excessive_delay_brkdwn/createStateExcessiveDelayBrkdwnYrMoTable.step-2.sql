------ https://npmrds.ritis.org/analytics/help/#npmrds
------ Can I download data averaged every X minutes?
----
----  The NPMRDS data is stored in 5-minute bins, but the Massive Data Downloader
----  tool lets you aggregate the data in 10-, 15-, 30-, or 60-minute bins to help
----  reduce the size of your results document.  When we aggregate the data:
----  
----      The timestamp represents the beginning of the chosen interval Speed are
----      calculated using the harmonic mean of the 5-minute values that fall within the
----      granularity bin you choose....

BEGIN;

ALTER TABLE "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
  ADD CONSTRAINT state_check 
    CHECK (state = '__STATE__'),
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  INHERIT "__STATE__".excessive_delay_brkdwn,
  SET (fillfactor = 100, autovacuum_enabled=false);


CREATE UNIQUE INDEX excessive_delay_brkdwn_y__YEAR__m__MONTH___idx
  ON "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__ (tmc)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
  ADD CONSTRAINT excessive_delay_brkdwn_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX excessive_delay_brkdwn_y__YEAR__m__MONTH___idx;

CLUSTER VERBOSE "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__
  USING excessive_delay_brkdwn_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".excessive_delay_brkdwn_y__YEAR__m__MONTH__;
