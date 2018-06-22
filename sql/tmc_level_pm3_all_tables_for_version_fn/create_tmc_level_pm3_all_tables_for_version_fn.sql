BEGIN;

CREATE OR REPLACE FUNCTION tmc_level_pm3_all_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            NPMRDS_VERSION_TYPE,
    tmcLevelPM3CalcVer   VARCHAR
  )
  RETURNS SETOF VARCHAR
  AS $body$
    SELECT
        '"' || schemaname || '".' || tablename AS leaf_table
      FROM pg_tables
      WHERE (
        (tablename LIKE 'pm3%')
        AND
        ( -- To avoid redundancy, if all params are null just return public schema table.
          CASE WHEN (
              (state IS NULL)
              AND
              (year IS NULL)
              AND
              (tmcLevelPM3CalcVer IS NULL)
            )
            THEN (schemaname = 'public')
            ELSE (schemaname <> 'public')
          END
        )
        AND
        ( -- A state is specified, return only table from its schema.
          CASE WHEN (state IS NOT NULL)
            THEN (schemaname = LOWER(state))
            ELSE true
          END
        )
        AND 
        ( -- One NPMRDS version, or the other... Never both
          CASE WHEN (npmrdsVer = '1'::NPMRDS_VERSION_TYPE)
            THEN (tablename LIKE 'pm3\_npmrdsv1%')
            ELSE (tablename NOT LIKE 'pm3\_npmrdsv1%')
          END
        )
        AND
        ( -- When a year is specified, return only year-level tables for that year.
          CASE WHEN (year IS NOT NULL)
            THEN (tablename ~ ('pm3(_npmrdsv1)?_' || year))
            ELSE true
          END
        )
        AND
        (
          CASE WHEN (tmcLevelPM3CalcVer IS NOT NULL)
            -- The version specified is the requested version
            THEN (tablename ~ ('_\d{4}_v' || tmcLevelPM3CalcVer || '$'))
            -- No version specified (default table)
            ELSE (tablename !~ '_\d{4}_v.*')
          END
        )
        AND
        ( -- When no year or tmcLevelPM3CalcVer, do not descend into the year-level tables.
          CASE WHEN ((year IS NULL) AND (tmcLevelPM3CalcVer IS NULL))
            THEN (tablename ~ 'pm3(_npmrdsv1)?$')
            ELSE true
          END
        )

      )
      ORDER BY 1
  $body$ LANGUAGE SQL
;

-- Convenience.. allow specifying npmrdsVer as NULL
CREATE OR REPLACE FUNCTION tmc_level_pm3_all_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            VARCHAR,
    tmcLevelPM3CalcVer   VARCHAR
  )
  RETURNS SETOF VARCHAR
  AS $body$
    SELECT tmc_level_pm3_all_tables_for_version_fn(
      state,
      year,
      npmrdsVer::NPMRDS_VERSION_TYPE,
      tmcLevelPM3CalcVer
    )
  $body$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION tmc_level_pm3_all_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            INTEGER,
    tmcLevelPM3CalcVer   VARCHAR
  )
  RETURNS SETOF VARCHAR
  AS $body$
    SELECT tmc_level_pm3_all_tables_for_version_fn(
      state,
      year,
      npmrdsVer::VARCHAR,
      tmcLevelPM3CalcVer
    )
  $body$ LANGUAGE SQL
;

COMMIT;
