BEGIN;

CREATE OR REPLACE VIEW pm3.npmrds_data_version_download_timestamps
  AS
    SELECT DISTINCT
        state,
        year,
        -- Get the latest download timestamp within a 6 day window
        --   because timestamps may be clustered when downloading multiple
        --   months at a time. We only want the final download timestamp
        --   for the cluster.
        first_value(npmrds_data_version_download_timestamp) OVER (
          PARTITION BY state, year
          ORDER BY npmrds_data_version_download_timestamp DESC
          RANGE BETWEEN '3 days' PRECEDING AND '3 days' FOLLOWING
        ) AS npmrds_data_version_download_timestamp
      FROM (
        SELECT
            table_schema AS state,
            SUBSTRING(table_name FROM 20 FOR 4)::INTEGER AS year,
            SUBSTRING(UPPER(table_name) FROM 26)::TIMESTAMP AS npmrds_data_version_download_timestamp
          FROM information_schema.tables
          WHERE (
            ( table_schema <> 'public' )
            AND
            ( table_name LIKE 'tmc_identification_%_v%' )
          )
      ) AS t
;

CREATE OR REPLACE VIEW pm3.tmc_metadata_version_timestamps
  AS
    SELECT DISTINCT
        table_schema AS state,
        SUBSTRING((table_name) FROM 14 FOR 4)::INTEGER AS year,
        (
          SUBSTRING((table_name) FROM 20 FOR 8)
          || 'T'
          || SUBSTRING((table_name) FROM 28)
        )::TIMESTAMP AS tmc_metadata_version_timestamp
      FROM information_schema.tables
      WHERE (
        ( table_schema <> 'public' )
        AND
        ( table_name LIKE 'tmc_metadata_%_v%' )
      )
;

CREATE OR REPLACE VIEW pm3.pm3_calculator_code_version_timestamps
  AS
    SELECT *
      FROM (
        SELECT DISTINCT ON (1)
            SUBSTRING(metadata->'gitRepoState'->>'hash' FROM 1 FOR 40) AS git_hash,
            (metadata->>'timestamp')::TIMESTAMP AS pm3_calculator_code_version_timestamp
          FROM pm3.pm3_calculator_metadata
          ORDER BY 1, 2
      ) AS t
    ;

--  DROP VIEW IF EXISTS pm3.pm3_calculator_data_provenances CASCADE;
CREATE OR REPLACE VIEW pm3.pm3_calculator_data_provenances
  AS
    SELECT
        id,
        jsonb_object_agg(
          state,
          jsonb_build_object(
            'calculator_run_timestamp',
            calculator_run_timestamp,
            'npmrds_data_version_download_timestamp',
            npmrds_data_version_download_timestamp,
            'tmc_metadata_version_timestamp',
            tmc_metadata_version_timestamp,
            'pm3_calculator_code_version_timestamp',
            pm3_calculator_code_version_timestamp
          )
        ) AS data_provenance_metadata
      FROM (
        SELECT
            m.id,
            -- NOTE: It is possible for the following to create multiple rows per calc run
            --       as multi-state runs are possible (eg, NYC UZA)
            jsonb_array_elements_text(metadata->'calculatorSettings'->'states') AS state,
            -- The above returns a single row per state. Below we get the full set of states in a run.
            string_to_array(
              regexp_replace(
                jsonb_pretty(
                  m.metadata->'calculatorSettings'->'states'
                ),
                '[\s\[\]"]',
                '',
                'g'
              ),
              ','
            ) AS states,
            (m.metadata->'calculatorSettings'->>'year')::INTEGER AS year,
            (m.metadata->>'timestamp')::TIMESTAMP AS calculator_run_timestamp,
            c.pm3_calculator_code_version_timestamp
          FROM pm3.pm3_calculator_metadata AS m
            LEFT OUTER JOIN pm3.pm3_calculator_code_version_timestamps AS c
              ON (
                SUBSTRING(m.metadata->'gitRepoState'->>'hash' FROM 1 FOR 40)
                =
                c.git_hash
              )
      ) AS t0
        LEFT OUTER JOIN LATERAL (
          SELECT
              npmrds_data_version_download_timestamp
            FROM pm3.npmrds_data_version_download_timestamps AS nddt
            WHERE (
              ( t0.state = nddt.state )
              AND
              ( t0.year = nddt.year )
              AND
              ( t0.calculator_run_timestamp > nddt.npmrds_data_version_download_timestamp )
            )
            -- We only want the npmrds_data_version_download_timestamp that
            --   immediately precedes that calculator_run_timestamp
            ORDER BY nddt.npmrds_data_version_download_timestamp DESC
            LIMIT 1
        ) AS t1 ON (true)
        LEFT OUTER JOIN LATERAL (
          SELECT
              tmc_metadata_version_timestamp
            FROM pm3.tmc_metadata_version_timestamps AS tmvt
            WHERE (
              ( t0.state = tmvt.state )
              AND
              ( t0.year = tmvt.year )
              AND
              ( t0.calculator_run_timestamp > tmvt.tmc_metadata_version_timestamp )
            )
            -- We only want the npmrds_data_version_download_timestamp that
            --   immediately precedes that calculator_run_timestamp
            ORDER BY tmvt.tmc_metadata_version_timestamp DESC
            LIMIT 1
        ) AS t2 ON (true)
      GROUP BY id
    ;

COMMIT;
