/*
  here_realtime_traffic_partitions table rolling

    Consolidates smaller time unit partition tables into larger time unit partitions.
*/
BEGIN;

DROP PROCEDURE IF EXISTS here_realtime_traffic_partitions.concatenate_here_realtime_partitions_proc();

CREATE OR REPLACE PROCEDURE here_realtime_traffic_partitions.concatenate_here_realtime_partitions_proc()
  LANGUAGE plpgsql
  AS $$
    DECLARE
      r RECORD;
      t TEXT;
    BEGIN
      FOR r IN
          SELECT
              'here_realtime_traffic_partitions.' || target_table_name AS full_tbl_name,
              target_table_name AS tbl_name,
              SUBSTRING(target_table_name FROM LENGTH('here_realtime_traffic_y')) AS suffix,
              source_tables
            FROM here_realtime_traffic_partitions._admin_pending_realtime_traffic_concatenations
      LOOP
        DECLARE
            start_timestamp   TIMESTAMP ;
            end_timestamp     TIMESTAMP ;

            error_message     TEXT;
            exception_detail  TEXT;
            exception_hint    TEXT;

        --  See:
        --      * https://www.postgresql.org/docs/11/plpgsql-transactions.html
        --      * https://www.postgresql.org/docs/11/plpgsql-control-structures.html#PLPGSQL-ERROR-TRAPPING
        BEGIN

          --  Need this nested block because of the exception handler within it.
          --    "A transaction cannot be ended inside a block with exception handlers."
          BEGIN

            RAISE NOTICE 'Concatenting into %', r.full_tbl_name;

            EXECUTE '
              CREATE TABLE ' || r.full_tbl_name || ' (
                  LIKE public.here_realtime_traffic
                )
              ;
            ';

            EXECUTE '
              SELECT
                  extent[1] AS start_timestamp,
                  extent[2] AS end_timestamp
                FROM (
                  SELECT here_realtime_traffic_partitions.here_timeframe_suffix_date_extent(
                    ''' || r.suffix || '''
                  ) AS extent
                ) AS t
              ;
            ' INTO start_timestamp, end_timestamp ;

            FOREACH t IN ARRAY r.source_tables::TEXT[]
            LOOP
              EXECUTE '
                INSERT INTO ' || r.full_tbl_name || '
                  SELECT
                      *
                    FROM ONLY ' || t || '
                ;
              ';
            END LOOP;

            EXECUTE '
              ALTER TABLE ' || r.full_tbl_name || '
                ADD CONSTRAINT ' || r.tbl_name || '_pkey
                  PRIMARY KEY (tmc, timestamp)
              ;

              ALTER INDEX ' || r.full_tbl_name || '_pkey
                SET (fillfactor = 100)
              ;

              CLUSTER ' || r.full_tbl_name || ' USING ' || r.tbl_name || '_pkey;
            ';

            FOREACH t IN ARRAY r.source_tables::TEXT[]
            LOOP
              EXECUTE 'DROP TABLE ' || t || ';';
            END LOOP;

            EXECUTE '
              ALTER TABLE public.here_realtime_traffic
                ATTACH PARTITION ' || r.full_tbl_name || '
                  FOR VALUES FROM (''' || start_timestamp || ''') TO (''' || end_timestamp || ''')
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

        -- Key for not locking the root public.here_realtime_traffic table.
        --   Breaks each partition tables roll into its own transaction.
        COMMIT;

        END;

      END LOOP;
    END;
$$;

COMMIT;
