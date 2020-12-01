BEGIN;

DROP VIEW IF EXISTS dbadmin.npmrds_table_storage_space;

CREATE VIEW dbadmin.npmrds_table_storage_space
  AS
    SELECT
        table_schema AS state,

        substring(table_name from 9 for 4) AS year,
        substring(table_name from 14 for 2) AS month,

        table_name,

        pg_relation_size(
          table_schema || '.' || table_name
        ) AS table_size_bytes,

        pg_indexes_size(
          table_schema || '.' || table_name
        ) AS indexes_size_bytes,

        pg_size_pretty(
          pg_relation_size(
            table_schema || '.' || table_name
          )
        ) AS table_size_h,

        pg_size_pretty(
          pg_indexes_size(
            table_schema || '.' || table_name
          )
        ) AS indexes_size_h

      FROM information_schema.tables
      WHERE ( table_name ~ '^npmrds_y\d{4}m\d{2}$' ) ;

COMMIT;
