BEGIN;

DROP FUNCTION IF EXISTS tmc_level_pm3_all_tables_for_version_fn (
    state                VARCHAR(2),
    year                 SMALLINT,
    npmrdsVer            NPMRDS_VERSION_TYPE,
    tmcLevelPM3CalcVer   VARCHAR
  )
;

COMMIT;
