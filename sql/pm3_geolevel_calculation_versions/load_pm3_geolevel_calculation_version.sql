BEGIN;

DELETE FROM pm3.pm3_geolevel_calculation_versions
  WHERE pm3calc_ver_id = (
    SELECT
        pm3calc_ver_id
      FROM pm3.pm3_calculation_versions_view
      WHERE ( version_id = :'VERSION_ID' )
  )
;

INSERT INTO pm3.pm3_geolevel_calculation_versions (
    pm3calc_ver_id,
    geolevel,
    geocode,
    states,
    state_codes,
    lottr_interstate,
    lottr_noninterstate,
    tttr_interstate,
    phed
  )
    SELECT
        pm3calc_ver_id,
        geolevel,
        geocode,
        states,
        state_codes,
        lottr_interstate,
        lottr_noninterstate,
        tttr_interstate,
        phed
      FROM pm3.calculate_pm3_geolevel_calculation_version(:'VERSION_ID')
;

COMMIT;
