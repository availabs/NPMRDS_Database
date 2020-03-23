BEGIN;

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
      ORDER BY 2
    ;

COMMIT;
