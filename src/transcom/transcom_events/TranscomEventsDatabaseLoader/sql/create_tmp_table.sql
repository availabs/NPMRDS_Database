-- Need to create a TEMP table when loading with a COPY FROM stream to handle PRIMARY KEY conflicts.
--   See https://stackoverflow.com/a/13949654/3970755

BEGIN;

DROP TABLE IF EXISTS __TMP_TABLE_NAME__ ;

CREATE TEMP TABLE __TMP_TABLE_NAME__
  AS
    SELECT *
      FROM transcom._transcom_historical_events
      WITH NO DATA;

COMMIT;
