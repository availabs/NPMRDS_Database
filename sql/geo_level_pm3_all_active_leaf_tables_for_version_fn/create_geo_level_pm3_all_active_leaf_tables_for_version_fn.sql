BEGIN;

CREATE OR REPLACE FUNCTION geo_level_pm3_all_active_leaf_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            NPMRDS_VERSION_TYPE,
    geoLevelPM3CalcVer   VARCHAR
  )
  RETURNS SETOF VARCHAR
  AS $body$
    SELECT
        '"' || pg_namespace.nspname || '".' || pg_class.relname
      FROM pg_inherits AS parents
        INNER JOIN pg_inherits AS this_generation
          ON (parents.inhrelid = this_generation.inhparent)
        LEFT OUTER JOIN pg_inherits AS children
          ON (this_generation.inhrelid = children.inhparent)
        INNER JOIN pg_class
          ON (this_generation.inhrelid = pg_class.oid)
        INNER JOIN pg_namespace
          ON (pg_class.relnamespace = pg_namespace.oid)
      WHERE (
        (pg_class.relname LIKE 'pm3%')
        AND
        (children.inhrelid IS NULL)
        AND
        (
          CASE WHEN (state IS NOT NULL)
            THEN (LOWER(state) = pg_namespace.nspname)
            ELSE true
          END
        )
        AND 
        ( -- One NPMRDS version, or the other... Never both
          CASE WHEN (npmrdsVer = '1'::NPMRDS_VERSION_TYPE)
            THEN (pg_class.relname LIKE 'pm3\_npmrdsv1%')
            ELSE (pg_class.relname NOT LIKE 'pm3\_npmrdsv1%')
          END
        )
        AND
        ( -- When a year is specified, return only year-level tables for that year.
          CASE WHEN (year IS NOT NULL)
            THEN (pg_class.relname ~ ('pm3(_npmrdsv1)?_' || year))
            ELSE true
          END
        )
        AND
        (
          CASE WHEN (geoLevelPM3CalcVer IS NOT NULL)
            -- The version specified is the requested version
            THEN (pg_class.relname ~ ('_\d{4}_v' || geoLevelPM3CalcVer || '$'))
            ELSE true
          END
        )
      )
      ORDER BY 1
  $body$ LANGUAGE SQL
;

-- Convenience.. allow specifying npmrdsVer as NULL
CREATE OR REPLACE FUNCTION geo_level_pm3_all_active_leaf_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            VARCHAR,
    geoLevelPM3CalcVer   VARCHAR
  )
  RETURNS SETOF VARCHAR
  AS $body$
    SELECT geo_level_pm3_all_active_leaf_tables_for_version_fn(
      state,
      year,
      npmrdsVer::NPMRDS_VERSION_TYPE,
      geoLevelPM3CalcVer
    )
  $body$ LANGUAGE SQL
;

CREATE OR REPLACE FUNCTION geo_level_pm3_all_active_leaf_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            INTEGER,
    geoLevelPM3CalcVer   VARCHAR
  )
  RETURNS SETOF VARCHAR
  AS $body$
    SELECT geo_level_pm3_all_active_leaf_tables_for_version_fn(
      state,
      year,
      npmrdsVer::VARCHAR,
      geoLevelPM3CalcVer
    )
  $body$ LANGUAGE SQL
;

COMMIT;
