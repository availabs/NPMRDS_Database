BEGIN;

DROP FUNCTION IF EXISTS geo_level_pm3_all_active_leaf_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            NPMRDS_VERSION_TYPE,
    geoLevelPM3CalcVer   VARCHAR
  )
;

DROP FUNCTION IF EXISTS geo_level_pm3_all_active_leaf_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            VARCHAR,
    geoLevelPM3CalcVer   VARCHAR
  )
;

DROP FUNCTION IF EXISTS geo_level_pm3_all_active_leaf_tables_for_version_fn (
    state                VARCHAR(2),
    year                 INTEGER,
    npmrdsVer            INTEGER,
    geoLevelPM3CalcVer   VARCHAR
  )
;

COMMIT;
