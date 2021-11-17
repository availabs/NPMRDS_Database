BEGIN ;

CREATE SCHEMA IF NOT EXISTS here_realtime_traffic_partitions;
CREATE SCHEMA IF NOT EXISTS here_npmrds_schema_partitions;

-- FIXME TODO: How will this handle pending concatenations of different levels?
--             EG: For week-level, concatenating day and hour level tables.
--                 Will the day-level tables appear as target and sources?
-- Where realtime-schema concatenation tables exist but corresponding npmrds-schema tables do not.
--  DROP VIEW IF EXISTS here_realtime_traffic_partitions._admin_pending_npmrds_schema_concatenations ;
CREATE PROCEDURE pg_temp.create_partitions_admin_view(table_schema TEXT)
  LANGUAGE plpgsql
  AS $$
    BEGIN

    EXECUTE '
      CREATE OR REPLACE VIEW here_' || table_schema || '_partitions._admin_pending_' || table_schema || '_concatenations
        AS
          WITH cte_existing_partition_tables AS (
            SELECT
                tablename
              FROM pg_catalog.pg_tables
              WHERE ( schemaname = ''here_' || table_schema || '_partitions'' )
          ), cte_target_table_name_universe AS (
            -- All possible target_table_names
            SELECT
                SUBSTRING(
                  tablename FROM 1 FOR LENGTH(''here_' || table_schema || '_yYYYYmMM'')
                ) AS target_table_name
              FROM cte_existing_partition_tables
              WHERE ( LENGTH(tablename) > LENGTH(''here_' || table_schema || '_yYYYYmMM'') )
            UNION
            SELECT
                SUBSTRING(
                  tablename FROM 1 FOR LENGTH(''here_' || table_schema || '_yYYYYmMMwW'')
                ) AS target_table_name
              FROM cte_existing_partition_tables
              WHERE ( LENGTH(tablename) > LENGTH(''here_' || table_schema || '_yYYYYmMMwW'') )
            UNION
            SELECT
                SUBSTRING(
                  tablename FROM 1 FOR LENGTH(''here_' || table_schema || '_yYYYYmMMwWdDD'')
                ) AS target_table_name
              FROM cte_existing_partition_tables
              WHERE ( LENGTH(tablename) > LENGTH(''here_' || table_schema || '_yYYYYmMMwWdDD'') )
            UNION
            SELECT
                SUBSTRING(
                  tablename FROM 1 FOR LENGTH(''here_' || table_schema || '_yYYYYmMMwWdDDhHH'')
                ) AS target_table_name
              FROM cte_existing_partition_tables
              WHERE ( LENGTH(tablename) > LENGTH(''here_' || table_schema || '_yYYYYmMMwWdDDhHH'') )
          ), cte_target_table_candidates AS (
            -- We must know that the target_table''s time frame is complete.
            --   We know this if there exists a table from the next time frame.
            --   Note: the following time-frame need not be complete, thus looking only as table prefix.
            SELECT
                target_table_name
              FROM cte_target_table_name_universe AS a
                INNER JOIN cte_existing_partition_tables AS b
                  ON (
                    -- There exists a partition table with a prefix of same length as a.target_table_name
                    --   where that prefix is lexicographical greater than target_table_name
                    ( a.target_table_name < SUBSTRING(b.tablename FROM 1 FOR LENGTH(a.target_table_name)) )
                  )

          ), cte_target_tables AS (
            -- There does not exist a target_table_name that is a proper prefix of the target_table_name
            --   otherwise the table that is the proper prefix should be the target_table.
            SELECT
                a.target_table_name
              FROM cte_target_table_candidates AS a
                LEFT OUTER JOIN cte_target_table_candidates AS b
                  -- NOTE: row from b cannot exist. See WHERE clause.
                  ON ( 
                    -- a is not b
                    ( a.target_table_name <> b.target_table_name )
                    AND
                    -- b is a prefix of a
                    ( STARTS_WITH( a.target_table_name, b.target_table_name ) )
                  )
              WHERE ( b.target_table_name IS NULL )
          )
            SELECT
                a.target_table_name,
                array_agg(
                  DISTINCT (''here_' || table_schema || '_partitions.'' || b.tablename)
                    ORDER BY (''here_' || table_schema || '_partitions.'' || b.tablename)
                ) AS source_tables
              FROM cte_target_tables AS a
                INNER JOIN cte_existing_partition_tables AS b
                ON (
                  ( a.target_table_name <> b.tablename )
                  AND
                  ( STARTS_WITH( b.tablename, a.target_table_name ) )
                )
              GROUP BY a.target_table_name
              ORDER BY a.target_table_name
      ;


    ' ;

    END;
$$;

CALL pg_temp.create_partitions_admin_view('realtime_traffic');
CALL pg_temp.create_partitions_admin_view('npmrds_schema');

COMMIT ;
