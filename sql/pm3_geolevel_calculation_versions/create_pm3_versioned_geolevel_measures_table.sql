BEGIN;

CREATE TABLE IF NOT EXISTS pm3.pm3_geolevel_calculation_versions (
  pm3calc_ver_id       INTEGER REFERENCES pm3.pm3_calculation_versions ON DELETE CASCADE NOT NULL,
  geolevel             TEXT,
  geocode              TEXT,
  states               TEXT[],
  state_codes          TEXT[],
  lottr_interstate     DOUBLE PRECISION,
  lottr_noninterstate  DOUBLE PRECISION,
  tttr_interstate      DOUBLE PRECISION,
  phed                 DOUBLE PRECISION,

  PRIMARY KEY(pm3calc_ver_id, geolevel, geocode, states)
);

CLUSTER pm3.pm3_geolevel_calculation_versions
  USING pm3_geolevel_calculation_versions_pkey;

CREATE OR REPLACE VIEW pm3.pm3_geolevel_calculation_versions_view
  AS
    SELECT
        pgcv.*,
        pcvv.measure_class,
        pcvv.year,
        pcvv.major_version,
        pcvv.minor_version,
        pcvv.fix_version,
        pcvv.prerelease_label,
        pcvv.pm3calc_ids,
        pcvv.changelog,
        pcvv.is_authoritative,
        pcvv.version_id
      FROM pm3.pm3_calculation_versions_view AS pcvv
        INNER JOIN pm3.pm3_geolevel_calculation_versions AS pgcv
          USING (pm3calc_ver_id)
;

COMMIT
