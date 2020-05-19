BEGIN;

-- https://stackoverflow.com/a/9981540

-- Can't use psql variables inside the function, so this is a work around.
CREATE TEMPORARY TABLE tmp_version_id_to_load
  ON COMMIT DROP
  AS SELECT :'VERSION_ID'::TEXT AS version_id;

CREATE FUNCTION pg_temp.tmp_load_pm3_geolevel_calculation_version ()
  RETURNS VOID AS
$func$
BEGIN

  IF NOT EXISTS (
      SELECT a.pm3calc_ver_id
         FROM pm3.pm3_calculation_versions_view AS a
         INNER JOIN tmp_version_id_to_load USING (version_id)
    ) THEN

      RAISE EXCEPTION 'version_id DOES NOT EXIST';

  END IF;


  DELETE FROM pm3.pm3_geolevel_calculation_versions AS pgcv
    WHERE pgcv.pm3calc_ver_id = (
      SELECT
          pm3calc_ver_id
        FROM pm3.pm3_calculation_versions_view AS pcvv
        INNER JOIN tmp_version_id_to_load USING (version_id)
    )
  ;

  EXECUTE '
      INSERT INTO pm3.pm3_geolevel_calculation_versions (
          pm3calc_ver_id,
          geolevel,
          geocode,
          states,
          state_codes,
          lottr_interstate,
          lottr_noninterstate,
          tttr_interstate,
          phed,
          interstate_tmcs,
          interstate_miles,
          noninterstate_tmcs,
          noninterstate_miles
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
              phed,
              interstate_tmcs,
              interstate_miles,
              noninterstate_tmcs,
              noninterstate_miles
            FROM ' || (
              SELECT
                  CASE minor_version
                    WHEN 1
                      THEN 'pm3.calculate_pm3_geolevel_calculation_version_v1_1'
                    ELSE 'pm3.calculate_pm3_geolevel_calculation_version_v1_2'
                  END || '(''' || (SELECT version_id FROM tmp_version_id_to_load) || '''::TEXT )'
                FROM pm3.pm3_calculation_versions_view
                  INNER JOIN tmp_version_id_to_load USING (version_id)
            ) || ';'
    ;
END;
$func$ LANGUAGE plpgsql;

SELECT pg_temp.tmp_load_pm3_geolevel_calculation_version();

DROP FUNCTION pg_temp.tmp_load_pm3_geolevel_calculation_version();

COMMIT;
