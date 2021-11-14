/*
  Consolidates smaller time unit partition tables into larger time unit partitions.

  NOTE: npmrds-schema concatenations only operate at day level or above.
        THEREFORE, epoch is not part of partitioning... only date range.

        Day-level table will need to be created in the hour-level epoch aggregations
          in order to inherit from the root npmrds-schmea table.
        In the PROCEDURE below,
          if the concatenation table is day-level,
            we must first
              1. uninherit the hour-level tables
              2. drop the abstract parent table
            before following the normal process.

*/
BEGIN;

DROP PROCEDURE IF EXISTS here_npmrds_schema_partitions.concatenate_here_npmrds_schema_partitions_proc();

CREATE OR REPLACE PROCEDURE here_npmrds_schema_partitions.concatenate_here_npmrds_schema_partitions_proc()
  LANGUAGE plpgsql
  AS $$
    DECLARE
      r RECORD;
      t TEXT;
    BEGIN
      FOR r IN
          SELECT
              'here_npmrds_schema_partitions.' || target_table_name AS full_tbl_name,
              target_table_name AS tbl_name,
              SUBSTRING(target_table_name FROM LENGTH('here_npmrds_schema_y')) AS suffix,
              source_tables
            FROM here_npmrds_schema_partitions._admin_pending_npmrds_schema_concatenations
      LOOP
        DECLARE
          target_table_extent       TIMESTAMP[2];

          table_copy_start_tstamp   TIMESTAMP;
          table_copy_end_tstamp     TIMESTAMP;
          table_copy_time_diff      NUMERIC;

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
            RAISE NOTICE 'Concatenting source tables into target_table %', r.full_tbl_name;

            EXECUTE '
              SELECT
                  here_realtime_traffic_partitions.here_timeframe_suffix_date_extent('''
                    || r.suffix ||
                  ''')
              ;' INTO target_table_extent ;

            -- If we are concatenating the hour tables into the day table the follow steps
            --   allow uniform handling with other level concatenations.
            IF LENGTH(r.tbl_name) = LENGTH('here_npmrds_schema_yYYYYmMMwWdDD')
              THEN
                RAISE NOTICE '  dropping abstract day-level table' ;
                -- Break the inheritance between the existing abstract day-level table and the hour tables.
                FOREACH t IN ARRAY r.source_tables::TEXT[]
                LOOP
                  EXECUTE 'ALTER TABLE ' || r.full_tbl_name || ' DETACH PARTITION ' || t || ';';
                END LOOP;

                -- Drop the existing abstract day-level table.
                EXECUTE 'DROP TABLE ' || r.full_tbl_name || ';';
            END IF;

            EXECUTE '
              CREATE TABLE ' || r.full_tbl_name || ' (
                  LIKE public.here_npmrds_schema
                )
              ;
            ';

            FOREACH t IN ARRAY r.source_tables::TEXT[]
            LOOP
              RAISE NOTICE '  copying % into %', t, r.full_tbl_name ;
              table_copy_start_tstamp := clock_timestamp() ;

              EXECUTE '
                INSERT INTO ' || r.full_tbl_name || '
                  SELECT
                      *
                    FROM ONLY ' || t || '
                ;
              ';

              table_copy_end_tstamp := clock_timestamp() ;
              table_copy_time_diff  := (
                                          EXTRACT(EPOCH FROM table_copy_end_tstamp)
                                          - EXTRACT(EPOCH FROM table_copy_start_tstamp)
                                       ) ;
              RAISE NOTICE '    % seconds', ROUND(table_copy_time_diff, 3) ;

            END LOOP;

            RAISE NOTICE '  adding target table indexes' ;

            table_copy_start_tstamp := clock_timestamp() ;

            EXECUTE '
              ALTER TABLE ' || r.full_tbl_name || '
                ADD CONSTRAINT ' || r.tbl_name || '_pkey
                  PRIMARY KEY (tmc, date, epoch)
              ;

              ALTER INDEX ' || r.full_tbl_name || '_pkey
                SET (fillfactor = 100)
              ;
            ';

            table_copy_end_tstamp := clock_timestamp() ;
            table_copy_time_diff  := (
                                        EXTRACT(EPOCH FROM table_copy_end_tstamp)
                                        - EXTRACT(EPOCH FROM table_copy_start_tstamp)
                                     ) ;
            RAISE NOTICE '    % seconds', ROUND(table_copy_time_diff, 3) ;


            RAISE NOTICE '  clustering target table' ;
            table_copy_start_tstamp := clock_timestamp() ;

            EXECUTE '
              CLUSTER ' || r.full_tbl_name || ' USING ' || r.tbl_name || '_pkey;
            ';

            table_copy_end_tstamp := clock_timestamp() ;
            table_copy_time_diff  := (
                                        EXTRACT(EPOCH FROM table_copy_end_tstamp)
                                        - EXTRACT(EPOCH FROM table_copy_start_tstamp)
                                     ) ;
            RAISE NOTICE '    % seconds', ROUND(table_copy_time_diff, 3) ;


            RAISE NOTICE '  dropping source tables' ;

            FOREACH t IN ARRAY r.source_tables::TEXT[]
            LOOP
              RAISE NOTICE '    %', t ;
              table_copy_start_tstamp := clock_timestamp() ;

              -- IF EXISTS BECAUSE POSSIBLE abstract day-level table drop cascades to hour-level tables.
              EXECUTE 'DROP TABLE IF EXISTS ' || t || ';';

              table_copy_end_tstamp := clock_timestamp() ;
              table_copy_time_diff  := (
                                          EXTRACT(EPOCH FROM table_copy_end_tstamp)
                                          - EXTRACT(EPOCH FROM table_copy_start_tstamp)
                                       ) ;
              RAISE NOTICE '      % seconds', ROUND(table_copy_time_diff, 3) ;
            END LOOP;

            RAISE NOTICE '  attaching target table to public.here_npmrds_schema' ;
            table_copy_start_tstamp := clock_timestamp() ;

            EXECUTE '
              ALTER TABLE public.here_npmrds_schema
                ATTACH PARTITION ' || r.full_tbl_name || '
                  FOR VALUES FROM (''' ||
                    target_table_extent[1]::DATE ||
                    ''') TO (''' ||
                    target_table_extent[2]::DATE ||
                  ''')
              ;
            ';

            table_copy_end_tstamp := clock_timestamp() ;
            table_copy_time_diff  := (
                                        EXTRACT(EPOCH FROM table_copy_end_tstamp)
                                        - EXTRACT(EPOCH FROM table_copy_start_tstamp)
                                     ) ;
            RAISE NOTICE '    % seconds', ROUND(table_copy_time_diff, 3) ;

          EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_message     = MESSAGE_TEXT,
                                    exception_detail  = PG_EXCEPTION_DETAIL,
                                    exception_hint    = PG_EXCEPTION_HINT;

              RAISE WARNING '%', error_message;
              RAISE WARNING '%', exception_detail;
              RAISE WARNING '%', exception_hint;
          END;

        -- Key for not locking the root public.here_npmrds_schema table.
        --   Breaks each partition tables roll into its own transaction.
        COMMIT;

        END;

      END LOOP;
    END;
$$;

COMMIT;
