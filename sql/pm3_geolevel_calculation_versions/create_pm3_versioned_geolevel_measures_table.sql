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
        sub_pcvv.measure_class,
        sub_pcvv.year,
        sub_pcvv.major_version,
        sub_pcvv.minor_version,
        sub_pcvv.fix_version,
        sub_pcvv.prerelease_label,
        sub_pcvv.pm3calc_ids,
        sub_pcvv.changelog,
        sub_pcvv.is_authoritative,
        sub_pcvv.version_id,
        pgcv.states,
        pgcv.state_codes,
        pgcv.lottr_interstate,
        pgcv.lottr_noninterstate,
        pgcv.tttr_interstate,
        pgcv.phed,
        jsonb_object_agg(
          (sub_pcvv.measure_metadata_kv).key,
          (sub_pcvv.measure_metadata_kv).value
        ) AS measure_metadata
      FROM (
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
            version_id,
            jsonb_each(measure_metadata) AS measure_metadata_kv
          FROM pm3.pm3_calculation_versions_view AS pcvv
      ) AS sub_pcvv INNER JOIN pm3.pm3_geolevel_calculation_versions AS pgcv
        ON (
          ( sub_pcvv.version_id = pgcv.version_id )
          AND
          ( (sub_pcvv.measure_metadata_kv).key = ANY(pgcv.states) )
        )
      GROUP BY (
        sub_pcvv.measure_class,
        sub_pcvv.year,
        sub_pcvv.major_version,
        sub_pcvv.minor_version,
        sub_pcvv.fix_version,
        sub_pcvv.prerelease_label,
        sub_pcvv.pm3calc_ids,
        sub_pcvv.changelog,
        sub_pcvv.is_authoritative,
        sub_pcvv.version_id,
        pgcv.states,
        pgcv.state_codes,
        pgcv.lottr_interstate,
        pgcv.lottr_noninterstate,
        pgcv.tttr_interstate,
        pgcv.phed
      )
;

COMMIT
