BEGIN;

CREATE OR REPLACE VIEW pm3.pm3_calculator_canonical_run_provenance
  AS
    SELECT
        *
      FROM (
        SELECT
            id AS pm3calc_id,
            metadata->>'state' AS state,
            metadata->'calculatorSettings'->>'year' AS year,
            (metadata->>'timestamp')::TIMESTAMP AS calculator_run_timestamp,
            SUBSTRING(metadata->'gitRepoState'->>'hash' FROM 1 FOR 40) AS git_hash
          FROM pm3.pm3_calculator_metadata
          WHERE metadata->>'state' <> 'false'
      ) AS t0
        INNER JOIN LATERAL (
          SELECT 
              state,
              SUBSTRING(UPPER(table_name) FROM 26)::TIMESTAMP AS npmrds_data_download_timestamp
            FROM information_schema.tables
            WHERE (
              ( table_schema = t0.state )
              AND
              ( table_name like ('tmc_identification_' || year || '_v%') )
              AND
              ( SUBSTRING(UPPER(table_name) FROM 26)::TIMESTAMP < calculator_run_timestamp )
            )
            ORDER BY npmrds_data_download_timestamp DESC
            LIMIT 1
        ) AS t1 USING (state)
        INNER JOIN LATERAL (
          SELECT 
              state,
              (
                SUBSTRING((table_name) FROM 20 FOR 8)
                || 'T'
                || SUBSTRING((table_name) FROM 28)
              )::TIMESTAMP AS tmc_metadata_version_timestamp
            FROM information_schema.tables
            WHERE (
              ( table_schema = t0.state )
              AND
              ( table_name like ('tmc_metadata_' || year || '_v%') )
              AND
              (
                (
                  SUBSTRING((table_name) FROM 20 FOR 8)
                  || 'T'
                  || SUBSTRING((table_name) FROM 28)
                )::TIMESTAMP < calculator_run_timestamp )
            )
            ORDER BY npmrds_data_download_timestamp DESC
            LIMIT 1
        ) AS t2 USING (state)
        ORDER BY pm3calc_id
    ;

COMMIT;
