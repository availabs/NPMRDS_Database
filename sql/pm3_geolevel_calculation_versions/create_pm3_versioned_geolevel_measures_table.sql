BEGIN;

CREATE TABLE IF NOT EXISTS pm3.pm3_geolevel_calculation_versions (
  version_id           TEXT,
  geolevel             TEXT,
  geocode              TEXT,
  states               TEXT[],
  state_codes          TEXT[],
  lottr_interstate     DOUBLE PRECISION,
  lottr_noninterstate  DOUBLE PRECISION,
  tttr_interstate      DOUBLE PRECISION,
  phed                 DOUBLE PRECISION,

  PRIMARY KEY(version_id, geolevel, geocode, states)
);

CLUSTER pm3.pm3_geolevel_calculation_versions
  USING pm3_geolevel_calculation_versions_pkey;

CREATE OR REPLACE VIEW pm3.pm3_geolevel_calculation_versions_view
  AS
    SELECT
        measure_class,
        year,
        major_version,
        minor_version,
        fix_version,
        prerelease_label,
        pm3calc_ids,
        changelog,
        is_authoritative,
        pgcv.*
      FROM pm3.pm3_calculation_versions_view AS pcvv
        INNER JOIN pm3.pm3_geolevel_calculation_versions AS pgcv USING (version_id)
;

COMMIT
