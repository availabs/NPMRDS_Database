BEGIN;

DROP FUNCTION IF EXISTS tmc_level_pm3_all_active_leaf_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            NPMRDS_VERSION_TYPE,
    tmcLevelPM3CalcVer   VARCHAR
  )
;

DROP FUNCTION IF EXISTS tmc_level_pm3_all_active_leaf_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            VARCHAR,
    tmcLevelPM3CalcVer   VARCHAR
  )
;

DROP FUNCTION IF EXISTS tmc_level_pm3_all_active_leaf_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            INTEGER,
    tmcLevelPM3CalcVer   VARCHAR
  )
;

COMMIT;
