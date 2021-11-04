/*
  TODO: Run npmrds-schema tables concatenation.
*/
BEGIN;

DROP PROCEDURE IF EXISTS here_npmrds_schema_partitions.update_here_npmrds_schema_tables_proc(
  tstamp TIMESTAMP
);

CREATE OR REPLACE PROCEDURE here_npmrds_schema_partitions.update_here_npmrds_schema_tables_proc(
  tstamp TIMESTAMP
)
  LANGUAGE plpgsql
  AS $$
    DECLARE
      param_tstamp_to_nearest_5min_predecessor  TIMESTAMP ;
      latest_realtime_traffic_epoch_timestamp   TIMESTAMP ;
      latest_npmrds_schema_epoch_timestamp      TIMESTAMP ;
      pending_epoch_tstamps                     TIMESTAMP[] ;
      tstamp_date                               DATE ;
      tstamp_epoch                              SMALLINT ;
      epoch_start_tstamp                        TIMESTAMP ;
    BEGIN
      SELECT
          date + ((epoch * 5)::TEXT || ' minutes')::INTERVAL
        INTO latest_npmrds_schema_epoch_timestamp
        FROM public.here_npmrds_schema_current ;

      IF ( latest_npmrds_schema_epoch_timestamp IS NULL )
        THEN
            DECLARE
              earliest_here_realtime_partition_table TEXT ;

            BEGIN
              -- Because querying the entire public.here_realtime_traffic_current can be very slow.
              SELECT
                  'here_realtime_traffic_partitions.' || MIN(tablename)
                INTO earliest_here_realtime_partition_table
                FROM pg_tables
                WHERE (
                  ( schemaname = 'here_realtime_traffic_partitions' )
                )
              ;

              EXECUTE '
                SELECT
                    (
                      DATE_TRUNC(''HOUR'', min_timestamp)
                      +
                      (
                        (
                          (
                            FLOOR( EXTRACT(''MINUTE'' FROM min_timestamp) / 5 )
                            * 5
                          ) - 5
                        )::TEXT || '' minutes''
                      )::INTERVAL
                    )
                  FROM (
                    SELECT
                        MIN(timestamp) AS min_timestamp
                      FROM ' || earliest_here_realtime_partition_table || '
                  ) AS t
                ;' INTO latest_npmrds_schema_epoch_timestamp
              ;
            END ;
      END IF;

      SELECT
          (
            DATE_TRUNC('HOUR', tstamp)
            +
            (
              (
                FLOOR( EXTRACT('MINUTE' FROM tstamp) / 5 )
                * 5
              )::TEXT
              || ' minutes'
            )::INTERVAL
          ) INTO param_tstamp_to_nearest_5min_predecessor ;

      IF ( latest_npmrds_schema_epoch_timestamp = param_tstamp_to_nearest_5min_predecessor )
        THEN RETURN;
      END IF;

      SELECT
          ARRAY(
            SELECT
                generate_series(
                  -- Epoch timestamp immediately following latest.
                  ( latest_npmrds_schema_epoch_timestamp + '5 minutes'::INTERVAL ),
                  param_tstamp_to_nearest_5min_predecessor,
                  '5 minutes'::INTERVAL
                )
          ) INTO pending_epoch_tstamps
      ;

      FOREACH epoch_start_tstamp IN ARRAY pending_epoch_tstamps
      LOOP
        DECLARE
            epoch_end_tstamp        TIMESTAMP ;

            tstamp_date             DATE ;
            tstamp_epoch            SMALLINT ;

            hour_start_epoch        SMALLINT ;
            hour_end_epoch          SMALLINT ;

            prev_epoch_date         DATE ;
            prev_epoch_epoch        SMALLINT ;

            full_parent_table_name  TEXT ;
            tbl_name                TEXT ;
            full_tbl_name           TEXT ;

            error_message           TEXT;
            exception_detail        TEXT;
            exception_hint          TEXT ;

        --  See:
        --      * https://www.postgresql.org/docs/11/plpgsql-transactions.html
        --      * https://www.postgresql.org/docs/11/plpgsql-control-structures.html#PLPGSQL-ERROR-TRAPPING
        BEGIN

          --  Need this nested block because of the exception handler within it.
          --    "A transaction cannot be ended inside a block with exception handlers."
          BEGIN

            RAISE NOTICE 'Creating table for %', epoch_start_tstamp;

            epoch_end_tstamp := epoch_start_tstamp + '5 minutes'::INTERVAL ;

            --  ASSERT DATE_TRUNC('HOUR', epoch_start_tstamp) = DATE_TRUNC('HOUR', epoch_end_tstamp),
              --  'epoch_start_tstamp and epoch_end_tstamp must be within the same hour'
            --  ;

            tstamp_date  := epoch_start_tstamp::DATE ;
            tstamp_epoch := (
                              ( EXTRACT('HOUR' FROM epoch_start_tstamp) * 12 )
                              +
                              ( FLOOR( EXTRACT('MINUTE' FROM epoch_start_tstamp) / 5 ) )
                            ) ;

            hour_start_epoch  := ( FLOOR( tstamp_epoch / 12 ) * 12 ) ;
            hour_end_epoch    := ( hour_start_epoch + 12 ) ;

            IF tstamp_epoch > 0
              THEN
                prev_epoch_date  := tstamp_date ;
                prev_epoch_epoch := tstamp_epoch - 1 ;
            ELSE
                prev_epoch_date  := ( tstamp_date - '1 day'::INTERVAL ) ;
                prev_epoch_epoch := 287 ;
            END IF ;

            EXECUTE '
              SELECT
                  ''here_npmrds_schema_partitions.here_npmrds_schema_''
                  || here_realtime_traffic_partitions.create_here_partition_timeframe_suffix_fn(
                    ''' || epoch_start_tstamp || ''',
                    ''DAY''
                  )
              ;' INTO full_parent_table_name ;

            EXECUTE '
              SELECT
                  ''here_npmrds_schema_''
                  || here_realtime_traffic_partitions.create_here_partition_timeframe_suffix_fn(
                    ''' || epoch_start_tstamp || ''',
                    ''HOUR''
                  )
              ;' INTO tbl_name ;

            full_tbl_name := 'here_npmrds_schema_partitions.' || tbl_name ;

            -- TODO: Create parent day-level table
            --       Create hour table partitioning the day-level table
            EXECUTE '
              CREATE TABLE IF NOT EXISTS ' || full_parent_table_name || '
                PARTITION OF public.here_npmrds_schema
                FOR VALUES
                  FROM (''' || tstamp_date || ''')
                  TO (''' || ( tstamp_date + '1 day'::INTERVAL ) || ''')
                PARTITION BY RANGE (epoch)
              ;
            ';

            EXECUTE '
              CREATE TABLE IF NOT EXISTS ' || full_tbl_name || '
                PARTITION OF ' || full_parent_table_name || '
                ( PRIMARY KEY (tmc, date, epoch) )
                FOR VALUES
                  FROM ( ' || hour_start_epoch || ' )
                  TO   ( ' || hour_end_epoch   || ' )
              ;
            ';

-- RAISE NOTICE '';
-- RAISE NOTICE '';
-- RAISE NOTICE '';
-- RAISE NOTICE 'epoch_start_tstamp: %', epoch_start_tstamp;
-- RAISE NOTICE 'epoch_end_tstamp: %', epoch_end_tstamp;
-- RAISE NOTICE 'tstamp_date: %', tstamp_date;
-- RAISE NOTICE 'tstamp_epoch: %', tstamp_epoch;
-- RAISE NOTICE '';
-- RAISE NOTICE '';
-- RAISE NOTICE '';

            EXECUTE '
              INSERT INTO ' || full_tbl_name || ' (
                tmc,
                date,
                epoch,
                travel_time_all_vehicles,
                staleness_minutes
              )
                WITH cte_nearby_tstamps AS (
                  SELECT DISTINCT
                      timestamp
                    FROM public.here_realtime_traffic
                    WHERE (
                      ( timestamp  > ''' || (epoch_start_tstamp - '5 minutes'::INTERVAL) || '''::TIMESTAMP )
                      AND
                      ( timestamp  < ''' || (epoch_end_tstamp   + '5 minutes'::INTERVAL) || '''::TIMESTAMP )
                    )
                ), cte_immediate_neighbor_timestamps AS (
                  SELECT
                      MAX(
                        LEAST(
                          timestamp,
                          ''' || ( epoch_start_tstamp - '5 minutes'::INTERVAL ) || '''::TIMESTAMP
                        )
                      ) AS immediate_predecessor_tstamp,
                      MIN(
                        GREATEST(
                          timestamp,
                          ''' || (epoch_end_tstamp   + '5 minutes'::INTERVAL) || '''::TIMESTAMP
                        )
                      ) AS immediate_successor_tstamp
                    FROM cte_nearby_tstamps
                ), cte_bin_tstamps AS (
                  SELECT
                      a.timestamp
                    FROM cte_nearby_tstamps AS a
                      INNER JOIN cte_immediate_neighbor_timestamps AS b
                        ON (
                          ( a.timestamp >= b.immediate_predecessor_tstamp )
                          AND
                          ( a.timestamp <= b.immediate_successor_tstamp )
                        )
                  UNION
                  SELECT ''' || epoch_end_tstamp || '''::TIMESTAMP
                ), cte_timebin_weights AS (
                  SELECT
                      bin_start_timestamp,
                      EXTRACT(EPOCH FROM UPPER(bin_overlap_range) - LOWER(bin_overlap_range)) AS weight
                    FROM (
                      SELECT
                          bin_start_timestamp,
                          (
                            bin_range
                            *
                            tsrange(
                              ''' || epoch_start_tstamp || '''::TIMESTAMP,
                              ''' || epoch_end_tstamp   || '''::TIMESTAMP
                            )
                          ) AS bin_overlap_range
                        FROM (
                          SELECT DISTINCT
                              start_ts AS bin_start_timestamp,
                              tsrange(start_ts, end_ts) AS bin_range
                            FROM (
                              SELECT
                                  a.timestamp AS start_ts,
                                  MIN(b.timestamp) OVER (PARTITION BY a.timestamp) AS end_ts
                                FROM cte_bin_tstamps AS a
                                  INNER JOIN cte_bin_tstamps AS b
                                    ON ( a.timestamp < b.timestamp )
                            ) AS t
                        ) AS t
                    ) AS t
                    WHERE ( UPPER(bin_overlap_range) IS NOT NULL )
                )
                SELECT
                    tmc,
                    ''' || tstamp_date  || '''::DATE AS date,
                    '   || tstamp_epoch || '::SMALLINT AS epoch,
                    (
                      SUM(travel_time * weight)
                      /
                      SUM(weight)
                    ) AS travel_time_all_vehicles,
                    0 AS staleness_minutes
                  FROM public.here_realtime_traffic AS a
                    INNER JOIN cte_timebin_weights AS b
                      ON (
                        a.timestamp = b.bin_start_timestamp
                      )
                  WHERE (
                    -- FIXME: Is this necessary for table pruning optimization?
                    ( a.timestamp  > ''' || (epoch_start_tstamp - '5 minutes'::INTERVAL) || '''::TIMESTAMP )
                    AND
                    ( a.timestamp  < ''' || (epoch_end_tstamp   + '5 minutes'::INTERVAL) || '''::TIMESTAMP )
                  )
                  GROUP BY tmc
              ;
            ';

            EXECUTE '
              -- Backfill, if necessary.
              INSERT INTO ' || full_tbl_name || ' (
                tmc,
                date,
                epoch,
                travel_time_all_vehicles,
                staleness_minutes
              )
                SELECT
                    tmc,
                    ''' || tstamp_date  || '''::DATE AS date,
                    '   || tstamp_epoch || '::SMALLINT AS epoch,
                    travel_time_all_vehicles,
                    ( staleness_minutes + 5 ) AS staleness_minutes
                  FROM public.here_npmrds_schema_current AS a
                ON CONFLICT (tmc, date, epoch)
                DO NOTHING
              ;
            ';

            EXECUTE '
              CREATE OR REPLACE VIEW public.here_npmrds_schema_current
                AS
                  SELECT
                      *
                    FROM ' || full_tbl_name || '
                    WHERE (
                      ( date = ''' || tstamp_date || '''::DATE )
                      AND
                      ( epoch = ' || tstamp_epoch || ' )
                    )
              ;

              CLUSTER ' || full_tbl_name || ' USING ' || tbl_name || '_pkey;
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

        CALL here_npmrds_schema_partitions.concatenate_here_npmrds_schema_partitions_proc() ;

        END;

      END LOOP;
    END;
$$;

COMMIT;
