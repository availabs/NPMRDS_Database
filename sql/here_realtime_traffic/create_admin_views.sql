BEGIN ;

CREATE SCHEMA IF NOT EXISTS here_realtime_traffic_partitions;

-- Below VIEW based on https://dba.stackexchange.com/a/221283

--  DROP VIEW IF EXISTS here_realtime_traffic_partitions._admin_parititon_summaries ;
CREATE OR REPLACE VIEW here_realtime_traffic_partitions._admin_parititon_summaries
  AS
    SELECT
        table_schema,
        table_name,
        start_timestamp,
        EXTRACT('YEAR'   FROM start_timestamp)::SMALLINT  AS start_year,
        EXTRACT('MONTH'  FROM start_timestamp)::SMALLINT  AS start_month,
        -- const w = Math.max(0, Math.floor((+day - 1) / 7)) + 1;
        (
          FLOOR (
            ( EXTRACT('DAY'    FROM start_timestamp)::SMALLINT - 1 )
            / 
            7
          ) + 1
        ) AS start_week,
        EXTRACT('DAY'    FROM start_timestamp)::SMALLINT  AS start_day,
        EXTRACT('HOUR'   FROM start_timestamp)::SMALLINT  AS start_hour,
        EXTRACT('MINUTE' FROM start_timestamp)::SMALLINT  AS start_minute,
        end_timestamp,
        EXTRACT('YEAR'   FROM end_timestamp)::SMALLINT    AS end_year,
        EXTRACT('MONTH'  FROM end_timestamp)::SMALLINT    AS end_month,
        (
          FLOOR(
            ( EXTRACT('DAY'    FROM end_timestamp)::SMALLINT - 1 )
            / 
            7
          ) + 1
        ) AS end_week,
        EXTRACT('DAY'    FROM end_timestamp)::SMALLINT    AS end_day,
        EXTRACT('HOUR'   FROM end_timestamp)::SMALLINT    AS end_hour,
        EXTRACT('MINUTE' FROM end_timestamp)::SMALLINT    AS end_minute
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
      ) AS t
;

DROP VIEW IF EXISTS here_realtime_traffic_partitions._admin_condensible_partitions ;
CREATE OR REPLACE VIEW here_realtime_traffic_partitions._admin_condensible_partitions
  AS
    WITH cte_month_condensible AS (
      SELECT DISTINCT
            'MONTH' AS condense_frame,
            (
              'here_realtime_traffic_'
              || 'y' || a.start_year::TEXT
              || 'm' || LPAD(a.start_month::TEXT, 2, '0')
            ) AS condensed_table_name,
            a.table_schema,
            a.table_name,
            DATE_TRUNC('MONTH', a.start_timestamp) AS start_timestamp,
            (DATE_TRUNC('MONTH', a.start_timestamp) + INTERVAL '1 month') AS end_timestamp
          FROM here_realtime_traffic_partitions._admin_parititon_summaries AS a
            INNER JOIN here_realtime_traffic_partitions._admin_parititon_summaries AS b
              ON (
                ( a.start_year = b.start_year )
                AND
                ( a.start_month < b.start_month )
                AND
                ( LENGTH(a.table_name) > 30 ) -- Exclude self
              )
    ), cte_week_condensible AS (
      SELECT DISTINCT
            'WEEK' AS condense_frame,
            (
              'here_realtime_traffic_'
              || 'y' || a.start_year::TEXT
              || 'm' || LPAD(a.start_month::TEXT, 2, '0')
              || 'w' || a.start_week
            ) AS condensed_table_name,
            a.table_schema,
            a.table_name,
            (
              DATE_TRUNC('MONTH', a.start_timestamp)
              + (((a.start_week - 1) * 7)::TEXT || ' days')::INTERVAL
            ) AS start_timestamp,
            LEAST(
              (
                DATE_TRUNC('MONTH', a.start_timestamp)
                + (((a.start_week) * 7)::TEXT || ' days')::INTERVAL
              ),
              (DATE_TRUNC('MONTH', a.start_timestamp) + INTERVAL '1 month')
            ) AS end_timestamp
          FROM here_realtime_traffic_partitions._admin_parititon_summaries AS a
            INNER JOIN here_realtime_traffic_partitions._admin_parititon_summaries AS b
              ON (
                ( a.start_year = b.start_year )
                AND
                ( a.start_month = b.start_month )
                AND
                ( a.start_week < b.start_week )
                AND
                ( LENGTH(a.table_name) > 32 ) -- Exclude self
              )
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
            'DAY' AS condense_frame,
            (
              'here_realtime_traffic_'
              || 'y' || a.start_year::TEXT
              || 'm' || LPAD(a.start_month::TEXT, 2, '0')
              || 'w' || a.start_week
              || 'd' || LPAD(a.start_day::TEXT, 2, '0')
            ) AS condensed_table_name,
            a.table_schema,
            a.table_name,
            DATE_TRUNC('DAY', a.start_timestamp) AS start_timestamp,
            (
              DATE_TRUNC('DAY', a.start_timestamp)
              + INTERVAL '1 day'
            ) AS end_timestamp
          FROM here_realtime_traffic_partitions._admin_parititon_summaries AS a
            INNER JOIN here_realtime_traffic_partitions._admin_parititon_summaries AS b
              ON (
                ( a.start_year = b.start_year )
                AND
                ( a.start_month = b.start_month )
                AND
                ( a.start_week = b.start_week )
                AND
                ( a.start_day < b.start_day )
                AND
                ( LENGTH(a.table_name) > 35 ) -- Exclude self
              )
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
            'HOUR' AS condense_frame,
            (
              'here_realtime_traffic_'
              || 'y' || a.start_year::TEXT
              || 'm' || LPAD(a.start_month::TEXT, 2, '0')
              || 'w' || a.start_week
              || 'd' || LPAD(a.start_day::TEXT, 2, '0')
              || 'h' || LPAD(a.start_hour::TEXT, 2, '0')
            ) AS condensed_table_name,
            a.table_schema,
            a.table_name,
            DATE_TRUNC('HOUR', a.start_timestamp) AS start_timestamp,
            (
              DATE_TRUNC('HOUR', a.start_timestamp)
              + INTERVAL '1 hour'
            ) AS end_timestamp
          FROM here_realtime_traffic_partitions._admin_parititon_summaries AS a
            INNER JOIN here_realtime_traffic_partitions._admin_parititon_summaries AS b
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
                ( LENGTH(a.table_name) > 38 ) -- Exclude self
              )
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
        condense_frame,
        condensed_table_name,
        start_timestamp,
        end_timestamp,
        array_agg(
          table_schema || '.' || table_name ORDER BY table_schema, table_name
        ) AS included_tables
      FROM cte_month_condensible
      GROUP BY condense_frame, condensed_table_name, start_timestamp, end_timestamp
    UNION ALL
    SELECT
        condense_frame,
        condensed_table_name,
        start_timestamp,
        end_timestamp,
        array_agg(
          table_schema || '.' || table_name ORDER BY table_schema, table_name
        ) AS included_tables
      FROM cte_week_condensible
      GROUP BY condense_frame, condensed_table_name, start_timestamp, end_timestamp
    UNION
    SELECT
        condense_frame,
        condensed_table_name,
        start_timestamp,
        end_timestamp,
        array_agg(
          table_schema || '.' || table_name ORDER BY table_schema, table_name
        ) AS included_tables
      FROM cte_day_condensible
      GROUP BY condense_frame, condensed_table_name, start_timestamp, end_timestamp
    UNION
    SELECT
        condense_frame,
        condensed_table_name,
        start_timestamp,
        end_timestamp,
        array_agg(
          table_schema || '.' || table_name ORDER BY table_schema, table_name
        ) AS included_tables
      FROM cte_hour_condensible
      GROUP BY condense_frame, condensed_table_name, start_timestamp, end_timestamp
    ORDER BY start_timestamp
;

COMMIT ;
