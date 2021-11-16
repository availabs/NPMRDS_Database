/*
  TODO: If ERROR encountered, loop should stop.
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

      error_message                             TEXT ;
      exception_detail                          TEXT ;
      exception_hint                            TEXT ;
    BEGIN

      -- Get 5 minutes past the current here_npmrds_schema timestamp.
      SELECT
          date + ((epoch * 5)::TEXT || ' minutes')::INTERVAL
        INTO latest_npmrds_schema_epoch_timestamp
        FROM public.here_npmrds_schema_current
        LIMIT 1
      ;

      -- If public.here_npmrds_schema_current was empty,
      --   then get the earliest epoch start timestamp from the realtime data.
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

      -- Get the array of 5-min timestamps between the latest_npmrds_schema_epoch_timestamp
      --   and the param_tstamp_to_nearest_5min_predecessor.
      --   These feed the CREATE TABLE loop below.
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
            npmrds_schema_current_timestamp   TIMESTAMP ;

            epoch_end_tstamp                  TIMESTAMP ;


            bin_start_timestamp_incl          TIMESTAMP ;
            bin_end_timestamp_excl            TIMESTAMP ;

            bin_realtime_first_tstamp_incl    TIMESTAMP ;
            bin_realtime_last_tstamp_incl     TIMESTAMP ;

            tstamp_date                       DATE ;
            tstamp_epoch                      SMALLINT ;

            hour_start_epoch                  SMALLINT ;
            hour_end_epoch                    SMALLINT ;

            prev_bin_date                     DATE ;
            prev_bin_epoch                    SMALLINT ;

            full_parent_table_name            TEXT ;
            tbl_name                          TEXT ;
            full_tbl_name                     TEXT ;


        --  See:
        --      * https://www.postgresql.org/docs/11/plpgsql-transactions.html
        --      * https://www.postgresql.org/docs/11/plpgsql-control-structures.html#PLPGSQL-ERROR-TRAPPING
        BEGIN

          BEGIN

            -- Timestamp minutes are a multiple of 5.
            IF ( ( EXTRACT('MINUTE' FROM epoch_start_tstamp)::INTEGER % 5 ) <> 0 )
              THEN
                RAISE EXCEPTION 'epoch_start_tstamp minutes must be a multiple of 5' ;
            END IF ;

            SELECT
                ( date + ( ( epoch * 5 )::TEXT || ' minutes' )::INTERVAL )
                INTO npmrds_schema_current_timestamp
                FROM public.here_npmrds_schema_current
            ;

            -- ===== Ensure no gaps in public.here_npmrds_schema =====
            -- It must be the case that either public.here_npmrds_schema_current is empty or
            --   its timestamp preceeds epoch_start_tstamp by exactly 5 minutes.
            IF (
                ( npmrds_schema_current_timestamp IS NOT NULL )
                AND
                ( ( epoch_start_tstamp - npmrds_schema_current_timestamp ) <> '5 minutes'::INTERVAL )
              ) THEN
                 RAISE EXCEPTION 'epoch_start_tstamp MUST be 5 minutes past public.here_npmrds_schema_current' ;
            END IF ;

            RAISE NOTICE 'Creating table for %', epoch_start_tstamp;

            epoch_end_tstamp    := epoch_start_tstamp + '5 minutes'::INTERVAL ;

            -- We potentially collect data from the previous/following 5min bin
            --   if the realtime data intervals overlap the current 5min bin.
            -- For example:
            --     12:00     12:05     12:10     12:15    -------- 5 minute bins
            --       |              |          |
            --     12:00          12:07      12:12        -------- Realtime bins
            --
            -- The 12:00-12:07 realtime data timebin overlaps the 12:05-12:10 5min time bin.
            --   Therefore, the measurements of the realtime bin should be included in the
            --   5min bin weighted average.
            bin_start_timestamp_incl := epoch_start_tstamp - '5 minutes'::INTERVAL ;
            bin_end_timestamp_excl   := epoch_end_tstamp   + '5 minutes'::INTERVAL ;

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
                prev_bin_date  := tstamp_date ;
                prev_bin_epoch := tstamp_epoch - 1 ;
            ELSE
                prev_bin_date  := ( tstamp_date - '1 day'::INTERVAL ) ;
                prev_bin_epoch := 287 ;
            END IF ;

            -- ===== Create the here_npmrds_schema tables =====

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

            -- Create abstract parent day-level table as a partition of the root here_npmrds_schema table.
            -- NOTE: Need the abstract day-level table because the root table is partitioned on date,
            --         while the epoch-level tables are partitioned on epoch.
            --         This differs from the here_realtime_traffic tables that are consistently
            --         partitioned by timestamp ranges.
            EXECUTE '
              CREATE TABLE IF NOT EXISTS ' || full_parent_table_name || '
                PARTITION OF public.here_npmrds_schema
                FOR VALUES
                  FROM (''' || tstamp_date || ''')
                  TO (''' || ( tstamp_date + '1 day'::INTERVAL ) || ''')
                PARTITION BY RANGE (epoch)
              ;
            ';

            -- Create the hour-level table as a partition of the day-level table.
            -- NOTE: Reason why multiple epochs per hour-level table, rather than table per epoch:
            --         The root here_npmrds_schema table is partitioned by date.
            --         If we were to have epoch-level tables, we would need to either
            --           * add an bstract hour-level table into the hierarchy
            --                  day-level
            --                     |
            --                     +- hour-level
            --                            |
            --                            +- epoch-level
            --
            --             which would complicate the table rolling/concatenation procedure
            --
            --           * have 288 epoch-level tables beneath the current date
            --
            -- NOTE: MUST use "IF NOT EXISTS" because hour-level table contains up to 12 epochs.
            EXECUTE '
              CREATE TABLE IF NOT EXISTS ' || full_tbl_name || '
                PARTITION OF ' || full_parent_table_name || '
                ( PRIMARY KEY (tmc, date, epoch) )
                FOR VALUES
                  FROM ( ' || hour_start_epoch || ' )
                  TO   ( ' || hour_end_epoch   || ' )
              ;
            ' ;

            -- Create a temporary table with data concerning the realtime data time bins.
            --   NOTE: bins_overlap_seconds is the number of seconds overlap between
            --         the realtime data time bin and the 5-minute time bin. This
            --         value is used to calcuate the weighted average of travel_times
            --         for a 5-minute time bin.
            EXECUTE '
              CREATE TEMPORARY TABLE tmp_included_realtime_timebins
                ON COMMIT DROP
                AS
                  WITH cte_candidate_bin_timestamps AS (
                    SELECT DISTINCT
                        timestamp
                      FROM public.here_realtime_traffic
                      WHERE (
                        timestamp
                          BETWEEN
                            ''' || bin_start_timestamp_incl || '''
                            AND
                            ''' || bin_end_timestamp_excl   || '''
                      )
                    UNION
                      SELECT ''' || bin_end_timestamp_excl || '''::TIMESTAMP AS timestamp
                  ), cte_candidate_realtime_bins AS (
                    SELECT DISTINCT
                        start_ts AS realtime_bin_start_timestamp,
                        tsrange(start_ts, end_ts) AS realtime_bin_timerange
                      FROM (
                        SELECT
                            a.timestamp AS start_ts,
                            MIN(b.timestamp) OVER (PARTITION BY a.timestamp) AS end_ts
                          FROM cte_candidate_bin_timestamps AS a
                            INNER JOIN cte_candidate_bin_timestamps AS b
                              ON ( a.timestamp < b.timestamp )
                      ) AS t
                  )
                    SELECT
                        realtime_bin_start_timestamp,
                        EXTRACT(
                          EPOCH FROM UPPER(bin_overlap_range) - LOWER(bin_overlap_range)
                        ) AS bins_overlap_seconds
                      FROM (
                        SELECT
                            realtime_bin_start_timestamp,
                            (
                              realtime_bin_timerange
                              *
                              tsrange(
                                ''' || epoch_start_tstamp || '''::TIMESTAMP,
                                ''' || epoch_end_tstamp   || '''::TIMESTAMP
                              )
                            ) AS bin_overlap_range
                          FROM cte_candidate_realtime_bins
                          WHERE (
                            realtime_bin_timerange
                            &&
                            tsrange(
                              ''' || epoch_start_tstamp || '''::TIMESTAMP,
                              ''' || epoch_end_tstamp   || '''::TIMESTAMP
                            )
                          )
                      ) AS t
             ;
            ' ;

            -- The [bin_realtime_first_tstamp_incl, bin_realtime_last_tstamp_incl] is the
            --   inclusive range of the here_realtime_traffic data to be used in the
            --   5-minute npmrds_schema travel_time_all_vehicles calculation.
            EXECUTE '
              SELECT
                  MIN(realtime_bin_start_timestamp) AS bin_realtime_first_tstamp_incl,
                  MAX(realtime_bin_start_timestamp) AS bin_realtime_last_tstamp_incl
                FROM tmp_included_realtime_timebins
            ;' INTO bin_realtime_first_tstamp_incl, bin_realtime_last_tstamp_incl ;

            -- NOTE: When there is a gap in the here_realtime_traffic data, the above EXECUTE INTO
            --       may not return any values. If this is the case, the below EXECUTE query string
            --       would be NULL, causing an error.
            IF (bin_realtime_first_tstamp_incl IS NOT NULL)
              THEN
                -- Creating the TEMP table and CLUSTERING it is a performance optimization.
                EXECUTE '
                  CREATE TEMPORARY TABLE tmp_included_realtime_traffic (
                    timestamp     TIMESTAMP,
                    tmc           TEXT,
                    travel_time   REAL,

                    PRIMARY KEY (timestamp, tmc)
                  ) ON COMMIT DROP ;

                  INSERT INTO tmp_included_realtime_traffic
                    SELECT
                        timestamp,
                        tmc,
                        travel_time
                      FROM public.here_realtime_traffic
                      WHERE (
                        timestamp
                          BETWEEN
                            ''' || bin_realtime_first_tstamp_incl || '''::TIMESTAMP
                            AND
                            ''' || bin_realtime_last_tstamp_incl   || '''::TIMESTAMP
                      )
                  ;

                  CLUSTER tmp_included_realtime_traffic USING tmp_included_realtime_traffic_pkey ;

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
                        (
                          SUM(travel_time * bins_overlap_seconds)
                          /
                          SUM(bins_overlap_seconds)
                        ) AS travel_time_all_vehicles,
                        0 AS staleness_minutes
                      FROM tmp_included_realtime_traffic AS a
                        INNER JOIN tmp_included_realtime_timebins AS b
                          ON (
                            a.timestamp = b.realtime_bin_start_timestamp
                          )
                      GROUP BY tmc
                  ;
                ' ;
            END IF ;

            -- Backfill, if necessary.
            EXECUTE '
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

            -- Update the here_npmrds_schema_current VIEW definition.
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

          --  EXCEPTION WHEN OTHERS THEN
              --  GET STACKED DIAGNOSTICS error_message     = MESSAGE_TEXT,
                                      --  exception_detail  = PG_EXCEPTION_DETAIL,
                                      --  exception_hint    = PG_EXCEPTION_HINT;

                --  RAISE WARNING '%', error_message;
                --  RAISE WARNING '%', exception_detail;
                --  RAISE WARNING '%', exception_hint;
          --  END;
          END ;

        -- Key for not locking the root public.here_realtime_traffic table.
        --   Breaks each partition tables roll into its own transaction.
        COMMIT;

        CALL here_npmrds_schema_partitions.concatenate_here_npmrds_schema_partitions_proc() ;

        END;

      END LOOP;
    END;
$$;

COMMIT;
