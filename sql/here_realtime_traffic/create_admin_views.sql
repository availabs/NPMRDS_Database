BEGIN ;

CREATE SCHEMA IF NOT EXISTS here_realtime_traffic_partitions;
CREATE SCHEMA IF NOT EXISTS here_npmrds_schema_partitions;


-- Below VIEW based on https://dba.stackexchange.com/a/221283

--  DROP VIEW IF EXISTS here_realtime_traffic_partitions._admin_here_realtime_partition_summaries ;
CREATE OR REPLACE VIEW here_realtime_traffic_partitions._admin_here_realtime_partition_summaries
  AS
    SELECT
        table_schema,
        table_name,

        start_timestamp,
        ( parsed_start_timestamp->>'year'   )::SMALLINT AS start_year,
        ( parsed_start_timestamp->>'month'  )::SMALLINT AS start_month,
        ( parsed_start_timestamp->>'week'   )::SMALLINT AS start_week,
        ( parsed_start_timestamp->>'day'    )::SMALLINT AS start_day,
        ( parsed_start_timestamp->>'hour'   )::SMALLINT AS start_hour,
        ( parsed_start_timestamp->>'minute' )::SMALLINT AS start_minute,

        end_timestamp,
        ( parsed_end_timestamp->>'year'     )::SMALLINT AS end_year,
        ( parsed_end_timestamp->>'month'    )::SMALLINT AS end_month,
        ( parsed_end_timestamp->>'week'     )::SMALLINT AS end_week,
        ( parsed_end_timestamp->>'day'      )::SMALLINT AS end_day,
        ( parsed_end_timestamp->>'hour'     )::SMALLINT AS end_hour,
        ( parsed_end_timestamp->>'minute'   )::SMALLINT AS end_minute
      FROM (
        SELECT
            pt.relnamespace::regnamespace::text AS table_schema,
            pt.relname AS table_name,
            substring(
              pg_get_expr(
                pt.relpartbound,
                pt.oid,
                TRUE
              ) FROM 19 for 19
            )::TIMESTAMP AS start_timestamp,
            substring(
              pg_get_expr(
                pt.relpartbound,
                pt.oid,
                TRUE
              ) FROM 46 for 19
            )::TIMESTAMP AS end_timestamp
          FROM pg_class base_tb
            INNER JOIN pg_inherits i
              ON ( i.inhparent = base_tb.oid )
            INNER JOIN pg_class pt
              ON ( pt.oid = i.inhrelid )
          WHERE ( base_tb.oid = 'public.here_realtime_traffic'::regclass )
      ) AS a, LATERAL (
        SELECT
            here_realtime_traffic_partitions.parse_timestamp_fn(
              a.start_timestamp
            ) AS parsed_start_timestamp,
            here_realtime_traffic_partitions.parse_timestamp_fn(
              a.end_timestamp
            ) AS parsed_end_timestamp
      ) AS b
;


--  DROP VIEW IF EXISTS here_realtime_traffic_partitions._admin_pending_realtime_concatenations ;
CREATE OR REPLACE VIEW here_realtime_traffic_partitions._admin_pending_realtime_concatenations
  AS
    WITH cte_month_condensible AS (
      SELECT DISTINCT
            'MONTH' AS concatenation_frame,
            'here_realtime_traffic_' || c.timeframe_suffix AS target_table_name,
            a.table_schema,
            a.table_name,
            d.date_extent[1] AS start_timestamp,
            d.date_extent[2] AS end_timestamp
          FROM here_realtime_traffic_partitions._admin_here_realtime_partition_summaries AS a
            INNER JOIN here_realtime_traffic_partitions._admin_here_realtime_partition_summaries AS b
              ON (
                ( a.start_year = b.start_year )
                AND
                ( a.start_month < b.start_month )
                AND
                ( LENGTH(a.table_name) > LENGTH('here_realtime_traffic_yYYYYmMM') ) -- Exclude self
              ),
            LATERAL (
              SELECT
                  here_realtime_traffic_partitions.create_here_partition_timeframe_suffix_fn(
                    a.start_timestamp,
                    'MONTH'
                  ) AS timeframe_suffix
            ) AS c,
            LATERAL (
              SELECT
                  here_realtime_traffic_partitions.here_timeframe_suffix_date_extent(
                    c.timeframe_suffix
                  ) AS date_extent
            ) AS d
    ), cte_week_condensible AS (
      SELECT DISTINCT
            'WEEK' AS concatenation_frame,
            'here_realtime_traffic_' || c.timeframe_suffix AS target_table_name,
            a.table_schema,
            a.table_name,
            d.date_extent[1] AS start_timestamp,
            d.date_extent[2] AS end_timestamp
          FROM here_realtime_traffic_partitions._admin_here_realtime_partition_summaries AS a
            INNER JOIN here_realtime_traffic_partitions._admin_here_realtime_partition_summaries AS b
              ON (
                ( a.start_year = b.start_year )
                AND
                ( a.start_month = b.start_month )
                AND
                ( a.start_week < b.start_week )
                AND
                ( LENGTH(a.table_name) > LENGTH('here_realtime_traffic_yYYYYmMMwW') ) -- Exclude self
              ),
            LATERAL (
              SELECT
                  here_realtime_traffic_partitions.create_here_partition_timeframe_suffix_fn(
                    a.start_timestamp,
                    'WEEK'
                  ) AS timeframe_suffix
            ) AS c,
            LATERAL (
              SELECT
                  here_realtime_traffic_partitions.here_timeframe_suffix_date_extent(
                    c.timeframe_suffix
                  ) AS date_extent
            ) AS d
          WHERE (
            (a.table_schema, a.table_name) NOT IN (
              SELECT
                  table_schema,
                  table_name
                FROM cte_month_condensible
            )
          )
    ), cte_day_condensible AS (
      SELECT DISTINCT
            'DAY' AS concatenation_frame,
            'here_realtime_traffic_' || c.timeframe_suffix AS target_table_name,
            a.table_schema,
            a.table_name,
            d.date_extent[1] AS start_timestamp,
            d.date_extent[2] AS end_timestamp
          FROM here_realtime_traffic_partitions._admin_here_realtime_partition_summaries AS a
            INNER JOIN here_realtime_traffic_partitions._admin_here_realtime_partition_summaries AS b
              ON (
                ( a.start_year = b.start_year )
                AND
                ( a.start_month = b.start_month )
                AND
                ( a.start_week = b.start_week )
                AND
                ( a.start_day < b.start_day )
                AND
                ( LENGTH(a.table_name) > LENGTH('here_realtime_traffic_yYYYYmMMwWdDD') ) -- Exclude self
              ),
            LATERAL (
              SELECT
                  here_realtime_traffic_partitions.create_here_partition_timeframe_suffix_fn(
                    a.start_timestamp,
                    'DAY'
                  ) AS timeframe_suffix
            ) AS c,
            LATERAL (
              SELECT
                  here_realtime_traffic_partitions.here_timeframe_suffix_date_extent(
                    c.timeframe_suffix
                  ) AS date_extent
            ) AS d
          WHERE (
            (a.table_schema, a.table_name) NOT IN (
              SELECT
                  table_schema,
                  table_name
                FROM cte_month_condensible
              UNION ALL
              SELECT
                  table_schema,
                  table_name
                FROM cte_week_condensible
            )
          )
    ), cte_hour_condensible AS (
      SELECT DISTINCT
            'HOUR' AS concatenation_frame,
            'here_realtime_traffic_' || c.timeframe_suffix AS target_table_name,
            a.table_schema,
            a.table_name,
            d.date_extent[1] AS start_timestamp,
            d.date_extent[2] AS end_timestamp
          FROM here_realtime_traffic_partitions._admin_here_realtime_partition_summaries AS a
            INNER JOIN here_realtime_traffic_partitions._admin_here_realtime_partition_summaries AS b
              ON (
                ( a.start_year = b.start_year )
                AND
                ( a.start_month = b.start_month )
                AND
                ( a.start_week = b.start_week )
                AND
                ( a.start_day = b.start_day )
                AND
                ( a.start_hour < b.start_hour )
                AND
                ( LENGTH(a.table_name) > LENGTH('here_realtime_traffic_yYYYYmMMwWdDDhHH') ) -- Exclude self
              ),
            LATERAL (
              SELECT
                  here_realtime_traffic_partitions.create_here_partition_timeframe_suffix_fn(
                    a.start_timestamp,
                    'HOUR'
                  ) AS timeframe_suffix
            ) AS c,
            LATERAL (
              SELECT
                  here_realtime_traffic_partitions.here_timeframe_suffix_date_extent(
                    c.timeframe_suffix
                  ) AS date_extent
            ) AS d
          WHERE (
            (a.table_schema, a.table_name) NOT IN (
              SELECT
                  table_schema,
                  table_name
                FROM cte_month_condensible
              UNION ALL
              SELECT
                  table_schema,
                  table_name
                FROM cte_week_condensible
              UNION ALL
              SELECT
                  table_schema,
                  table_name
                FROM cte_day_condensible
            )
          )
    )
    SELECT
        concatenation_frame,
        target_table_name,
        start_timestamp,
        end_timestamp,
        array_agg(
          table_schema || '.' || table_name ORDER BY table_schema, table_name
        ) AS source_tables
      FROM cte_month_condensible
      GROUP BY concatenation_frame, target_table_name, start_timestamp, end_timestamp
    UNION ALL
    SELECT
        concatenation_frame,
        target_table_name,
        start_timestamp,
        end_timestamp,
        array_agg(
          table_schema || '.' || table_name ORDER BY table_schema, table_name
        ) AS source_tables
      FROM cte_week_condensible
      GROUP BY concatenation_frame, target_table_name, start_timestamp, end_timestamp
    UNION
    SELECT
        concatenation_frame,
        target_table_name,
        start_timestamp,
        end_timestamp,
        array_agg(
          table_schema || '.' || table_name ORDER BY table_schema, table_name
        ) AS source_tables
      FROM cte_day_condensible
      GROUP BY concatenation_frame, target_table_name, start_timestamp, end_timestamp
    UNION
    SELECT
        concatenation_frame,
        target_table_name,
        start_timestamp,
        end_timestamp,
        array_agg(
          table_schema || '.' || table_name ORDER BY table_schema, table_name
        ) AS source_tables
      FROM cte_hour_condensible
      GROUP BY concatenation_frame, target_table_name, start_timestamp, end_timestamp
    ORDER BY start_timestamp
;

-- FIXME TODO: How will this handle pending concatenations of different levels?
--             EG: For week-level, concatenating day and hour level tables.
--                 Will the day-level tables appear as target and sources?
-- Where realtime-schema concatenation tables exist but corresponding npmrds-schema tables do not.
--  DROP VIEW IF EXISTS here_realtime_traffic_partitions._admin_pending_npmrds_schema_concatenations ;
CREATE OR REPLACE VIEW here_npmrds_schema_partitions._admin_pending_npmrds_schema_concatenations
  AS
    SELECT
        a.tablename AS target_table_name,
        array_agg(
          'here_npmrds_schema_partitions.' || b.tablename ORDER BY b.tablename
        ) AS source_tables
      FROM (
        SELECT
            -- The pending npmrds_schema concatenation table name
            REPLACE(tablename, 'realtime_traffic', 'npmrds_schema') AS tablename
          FROM pg_tables
          WHERE (
            ( schemaname = 'here_realtime_traffic_partitions' )
          )
        ) AS a INNER JOIN (
          SELECT
              tablename
            FROM pg_tables
        ) AS b ON ( b.tablename LIKE ( a.tablename || '_%' ) -- a.tablename is a proper prefix of b.tablename
      )
      WHERE (
        (
          -- INVARIANT: no pending realtime table concatenations
          NOT EXISTS (
            SELECT
              FROM here_realtime_traffic_partitions._admin_pending_realtime_concatenations
          )
        )
        AND
        (
          -- INVARIANT: There exists a npmrds-schema table with a date greater than the to-be-concatenated
          --            npmrds-schema tables. This guarantees that we do not concatenate into a day-level
          --            npmrds-schema table an hour-level table with pending realtime data aggregations.
          ( SUBSTRING(b.tablename FROM 1 FOR LENGTH('here_npmrds_schema_yYYYYmMMwWdDD') ) )
          < (
              SELECT
                  SUBSTRING(
                    MAX(c.tablename) FROM 1 FOR LENGTH('here_npmrds_schema_yYYYYmMMwWdDD')
                  )
                FROM pg_tables AS c
                WHERE ( c.schemaname = 'here_npmrds_schema_partitions' )
            )
        )
      )
      GROUP BY a.tablename
      ORDER BY LENGTH(a.tablename) DESC
;

COMMIT ;
