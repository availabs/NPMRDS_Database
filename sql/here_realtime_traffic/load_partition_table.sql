\set tbl_name 'here_realtime_traffic_':PARTITION_TABLE_SUFFIX
\set full_tbl_name 'here_realtime_traffic_partitions.':tbl_name
\set pkey_idx_name 'here_realtime_traffic_':PARTITION_TABLE_SUFFIX'_pkey'
\set full_pkey_idx_name 'here_realtime_traffic_partitions.here_realtime_traffic_':PARTITION_TABLE_SUFFIX'_pkey'

BEGIN;

CREATE TEMPORARY TABLE tmp_timestamp
  AS
    SELECT
        :'TIME_RANGE_START'::TIMESTAMP WITHOUT TIME ZONE AS timestamp
;

DO
$$
BEGIN

  IF (
      ( SELECT timeStamp FROM tmp_timestamp )
      <= ( SELECT timestamp FROM public.here_realtime_traffic_current LIMIT 1 )
    ) THEN
      RAISE EXCEPTION 'Cannot load. TIME_RANGE_START <= timestamp in here_realtime_traffic_current.';
  END IF;

END
$$;

DROP TABLE tmp_timestamp ;

-- Because we cannot use variables in \COPY, we need a known table name into which to load the CSV.
--   We need to use :TABLE_COLS to make sure the CSV column order is the same as the table col order.
-- SEE: https://www.postgresql.org/docs/current/app-psql.html#APP-PSQL-META-COMMANDS-COPY
CREATE TEMPORARY TABLE tmp_loader_table
  AS
    SELECT
        :TABLE_COLS
      FROM public.here_realtime_traffic
      LIMIT 0
;

\COPY tmp_loader_table FROM PSTDIN WITH ( FORMAT CSV, HEADER, DELIMITER (',') ) ;

DO
$$
BEGIN

  IF NOT EXISTS (
      SELECT
          tmc,
          travel_time,
          confidence,
          jam_factor
        FROM tmp_loader_table
      EXCEPT
      SELECT
          tmc,
          travel_time,
          confidence,
          jam_factor
        FROM public.here_realtime_traffic_current
    )
    THEN
      RAISE EXCEPTION 'Loaded data is duplicate of latest loaded data.';
  END IF;

END
$$;

CREATE SCHEMA IF NOT EXISTS here_realtime_traffic_partitions;

CREATE TABLE :full_tbl_name (
  LIKE public.here_realtime_traffic
) WITH (fillfactor=100, autovacuum_enabled=false) ;

ALTER TABLE :full_tbl_name
  ALTER COLUMN timestamp
    SET DEFAULT :'TIME_RANGE_START'::TIMESTAMP WITHOUT TIME ZONE
;

INSERT INTO :full_tbl_name (:TABLE_COLS)
  SELECT
      :TABLE_COLS
    FROM tmp_loader_table
;

DROP TABLE tmp_loader_table;

ALTER TABLE :full_tbl_name
  ADD CONSTRAINT :pkey_idx_name
    PRIMARY KEY (tmc)
;

ALTER INDEX :full_pkey_idx_name
  SET (fillfactor = 100);

ALTER TABLE public.here_realtime_traffic
  ATTACH PARTITION :full_tbl_name
    FOR VALUES FROM (:'TIME_RANGE_START') TO (:'TIME_RANGE_END')
;

CLUSTER :full_tbl_name USING :pkey_idx_name;

CREATE OR REPLACE VIEW public.here_realtime_traffic_current
  AS
    SELECT
        *
      FROM :full_tbl_name
;

COMMIT;

ANALYZE :full_tbl_name ;

-- CONSIDER: Is this the best place for this?
--
--             Pro: Tightly couples partition rolling with loading.
--             Con: Potentially slows down realtime loader.
CALL here_realtime_traffic_partitions._admin_consolidate_partitions() ;
