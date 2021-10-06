/*
  here_realtime_traffic_partitions table rolling

    Consolidates partition tables.
*/
BEGIN;

DROP FUNCTION IF EXISTS here_realtime_traffic_partitions._admin_consolidate_partitions();
DROP PROCEDURE IF EXISTS here_realtime_traffic_partitions._admin_consolidate_partitions();

CREATE OR REPLACE PROCEDURE here_realtime_traffic_partitions._admin_consolidate_partitions()
  LANGUAGE plpgsql
  AS $$
    DECLARE
      r RECORD;
      t TEXT;
    BEGIN
      FOR r IN
          SELECT
              'here_realtime_traffic_partitions.' || condensed_table_name AS full_tbl_name,
              condensed_table_name AS tbl_name,
              start_timestamp,
              end_timestamp,
              included_tables
            FROM here_realtime_traffic_partitions._admin_condensible_partitions
      LOOP
        DECLARE
            error_message     text;
            exception_detail  text;
            exception_hint    text;

        -- https://www.postgresql.org/docs/11/plpgsql-control-structures.html#PLPGSQL-ERROR-TRAPPING
        BEGIN

          RAISE NOTICE 'Creating %', r.full_tbl_name;

          EXECUTE '
            CREATE TABLE ' || r.full_tbl_name || ' (
                LIKE public.here_realtime_traffic
              )
            ;

            INSERT INTO ' || r.full_tbl_name || '
              SELECT
                  *
                FROM public.here_realtime_traffic
                WHERE ( 
                  ( timestamp >= ''' || r.start_timestamp || '''::TIMESTAMP WITHOUT TIME ZONE )
                  AND
                  ( timestamp < ''' || r.end_timestamp || '''::TIMESTAMP WITHOUT TIME ZONE )
                )
            ;

            ALTER TABLE ' || r.full_tbl_name || '
              ADD CONSTRAINT ' || r.tbl_name || '_pkey
                PRIMARY KEY (tmc, timestamp)
            ;

            ALTER INDEX ' || r.full_tbl_name || '_pkey
              SET (fillfactor = 100)
            ;

            CLUSTER ' || r.full_tbl_name || ' USING ' || r.tbl_name || '_pkey;
          ';

          FOREACH t IN ARRAY r.included_tables::TEXT[]
          LOOP
            EXECUTE 'DROP TABLE ' || t || ';';
          END LOOP;

          EXECUTE '
            ALTER TABLE public.here_realtime_traffic
              ATTACH PARTITION ' || r.full_tbl_name || '
                FOR VALUES FROM (''' || r.start_timestamp || ''') TO (''' || r.end_timestamp || ''')
            ;
          ';

        EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_message     = MESSAGE_TEXT,
                                    exception_detail  = PG_EXCEPTION_DETAIL,
                                    exception_hint    = PG_EXCEPTION_HINT;

              RAISE WARNING '%', error_message;
              RAISE WARNING '%', exception_detail;
              RAISE WARNING '%', exception_hint;
        END;

      END LOOP;
    END;
$$;

COMMIT;
