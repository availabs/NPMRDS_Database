BEGIN;

-- TODO: Add a TRIGGER that enforces the following rules:
--       1. Each measure once per state
--       2. No mingling of canonical and non-canonical
CREATE TABLE IF NOT EXISTS pm3.pm3_calculation_versions (
  id                 SERIAL PRIMARY KEY,
  year               SMALLINT NOT NULL,
  measure_class      TEXT NOT NULL,
  major_version      SMALLINT NOT NULL,
  minor_version      SMALLINT NOT NULL,
  fix_version        SMALLINT NOT NULL,
  prerelease_label   TEXT,
  pm3calc_ids        INTEGER[],
  changelog          TEXT,
  is_authoritative   BOOLEAN DEFAULT FALSE

  CHECK (
    ( ( fix_version <> 0 ) AND ( prerelease_label IS NULL ) )
    OR
    ( ( fix_version = 0 ) AND ( prerelease_label IS NOT NULL ) )
  )
) ;

CREATE UNIQUE INDEX IF NOT EXISTS pm3_calculation_versions_release_uniq
  ON pm3.pm3_calculation_versions (
    year,
    measure_class,
    major_version,
    minor_version,
    fix_version
  ) WHERE (prerelease_label IS NULL)
;

CREATE UNIQUE INDEX IF NOT EXISTS pm3_calculation_versions_prerelease_uniq
  ON pm3.pm3_calculation_versions (
    measure_class,
    year,
    major_version,
    minor_version,
    fix_version,
    prerelease_label
  ) WHERE (prerelease_label IS NOT NULL)
;

/*
  TODO:
    0. All pm3calc_ids in pm3_calculator_metadata (on DELETE from pm3_calculator_metadata too)
    1. Add CHECK to make sure only one instance of a measure per state
    2. TMC_METADATA version should immediately precede the calculation
    3. Only one authoritative per year/measure_class.
*/
CREATE OR REPLACE FUNCTION pm3_calculation_versions_rules_fn()
  RETURNS TRIGGER
  AS $pm3_calculation_versions_rules_fn$
    DECLARE
      missing_tmc_metadata_calc_ids TEXT;

    BEGIN
      SELECT
          string_agg(
            t.state,
            ','
          ) INTO missing_tmc_metadata_calc_ids
        FROM (
          SELECT
              jsonb_array_elements_text(metadata->'calculatorSettings'->'states') AS state
            FROM pm3.pm3_calculator_metadata AS pcm
            WHERE ( pcm.id = ANY(NEW.pm3calc_ids) )
          EXCEPT
          SELECT
              jsonb_array_elements_text(metadata->'calculatorSettings'->'states') AS state
            FROM pm3.pm3_calculator_metadata AS pcm
            WHERE (
              ( pcm.id = ANY(NEW.pm3calc_ids) )
              AND
              ( metadata->'calculatorSettings'->>'outputHPMSRequiredTmcMetadata' = 'true' )
            )
        ) AS t;

        IF ( missing_tmc_metadata_calc_ids IS NOT NULL ) THEN
          RAISE EXCEPTION
            'ERROR Loading: %_%:%.%.% % The following states do not have a pm3calc_id with TMC_METADATA: %',
            NEW.measure_class,
            NEW.year,
            NEW.major_version,
            NEW.minor_version,
            NEW.fix_version,
            CASE
              WHEN (NEW.prerelease_label IS NULL) THEN ''
              ELSE (':' || NEW.prerelease_label)
            END,
            missing_tmc_metadata_calc_ids;
        END IF;

        RETURN NEW;
    END;
  $pm3_calculation_versions_rules_fn$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS pm3_calculation_versions_rules_trigger
  ON pm3.pm3_calculation_versions
;

CREATE TRIGGER pm3_calculation_versions_rules_trigger
  AFTER INSERT OR UPDATE
  ON pm3.pm3_calculation_versions
  FOR EACH ROW
  EXECUTE FUNCTION pm3_calculation_versions_rules_fn()
;

DROP VIEW IF EXISTS pm3.pm3_calculation_versions_view CASCADE;

CREATE OR REPLACE VIEW pm3.pm3_calculation_versions_view
  AS
    SELECT
        pcv.pm3calc_ver_id,
        pcv.measure_class,
        year,
        major_version,
        minor_version,
        fix_version,
        prerelease_label,
        pm3calc_ids,
        changelog,
        is_authoritative,
        version_id,
        available_measures,
        measure_metadata
      FROM (
        SELECT
            id AS pm3calc_ver_id,
            measure_class,
            year,
            major_version,
            minor_version,
            fix_version,
            prerelease_label,
            pm3calc_ids,
            changelog,
            is_authoritative,
            (
             measure_class
             || '_'
             || year
             || ':'
             || major_version
             || '.'
             || minor_version
             || '.'
             || COALESCE(fix_version::TEXT, 'x')
             || CASE
               WHEN (prerelease_label IS NOT NULL)
                 THEN ':' || prerelease_label
               ELSE ''
             END
            ) AS version_id,
            t.available_measures
          FROM pm3.pm3_calculation_versions AS pcv
            LEFT OUTER JOIN LATERAL (
              SELECT
                  array_agg(
                    DISTINCT measure_calc_config->>'measure'
                      ORDER BY measure_calc_config->>'measure'
                  ) AS available_measures
                FROM (
                  SELECT
                      jsonb_array_elements(metadata->'calculators') AS measure_calc_config
                    FROM pm3.pm3_calculator_metadata AS pcm
                    WHERE ( pcm.id = ANY( pcv.pm3calc_ids ) )
                  UNION
                  SELECT
                      jsonb_build_object(
                        'year',
                        (metadata->'calculatorSettings'->>'year')::INTEGER,
                        'measure',
                        'TMC_METADATA',
                        'isCanonical',
                        true
                      ) AS measure_calc_config
                    FROM pm3.pm3_calculator_metadata AS pcm
                    WHERE (
                      ( pcm.id = ANY( pcv.pm3calc_ids ) )
                      AND
                      ( (pcm.metadata->'calculatorSettings'->'outputHPMSRequiredTmcMetadata')::BOOLEAN )
                    )
                  UNION
                  SELECT
                      jsonb_build_object(
                        'year',
                        (metadata->'calculatorSettings'->>'year')::INTEGER,
                        'measure',
                        'RIS_METADATA',
                        'isCanonical',
                        true
                      ) AS measure_calc_config
                    FROM pm3.pm3_calculator_metadata AS pcm
                    WHERE (
                      ( pcm.id = ANY( pcv.pm3calc_ids ) )
                      AND
                      ( (pcm.metadata->'calculatorSettings'->>'measures') LIKE '%_RIS%' )
                    )
                ) AS t0
                WHERE (
                  (
                    CASE pcv.measure_class
                      -- FHWA MUST be canonical versions of LOTTR, TTTR, of PHED
                      WHEN 'FHWA' THEN (
                        (
                          (
                            UPPER(measure_calc_config->>'measure')
                              = ANY(ARRAY['LOTTR', 'TTTR', 'PHED'])
                          )
                          AND
                          ( measure_calc_config->>'isCanonical' = 'true' )
                        )
                        OR
                        ( measure_calc_config->>'measure' = 'TMC_METADATA' )
                      )
                      -- RIS measures must have the RIS_ prefix or _RIS suffix.
                      WHEN 'RIS' THEN (
                        ( measure_calc_config->>'measure' LIKE 'RIS_%' )
                        OR
                        ( measure_calc_config->>'measure' LIKE '%_RIS' )
                        OR
                        ( measure_calc_config->>'measure' = 'TMC_METADATA' )
                      )
                      WHEN 'AUX' THEN (
                        (
                          -- Not Canonical Version of FHWA (per CFR Section 490)
                          (
                            -- Not one of the FHWA measures
                            (
                              UPPER(measure_calc_config->>'measure')
                                <> ALL(ARRAY['LOTTR', 'TTTR', 'PHED'])
                            )
                            OR
                            -- Not canonical version of the FHWA measure
                            ( measure_calc_config->>'isCanonical' <> 'true' )
                          )
                          AND
                          -- Not RIS-based
                          (
                            ( measure_calc_config->>'measure' NOT LIKE 'RIS_%' )
                            AND
                            ( measure_calc_config->>'measure' NOT LIKE '%_RIS' )
                          )
                        )
                        OR
                        ( measure_calc_config->>'measure' = 'TMC_METADATA' )
                      )
                      ELSE false
                  END
                )
              )
            ) AS t ON (true)
        ) AS pcv LEFT OUTER JOIN LATERAL (
            SELECT
                jsonb_object_agg(
                  state,
                  state_measure_metadata
                ) AS measure_metadata
              FROM (
                SELECT
                  state,
                  jsonb_object_agg(
                    measure_calc_config->>'measure',
                    (
                      jsonb_build_object(
                        'pm3_calc_run_id',
                        pm3_calc_run_id
                      )
                      ||
                      ( measure_calc_config - 'outputFileName' )
                      ||
                      COALESCE(data_provenance_metadata, '{}'::JSONB)
                    )
                    ORDER BY pm3_calc_run_id, measure_calc_config->>'measure'
                  ) AS state_measure_metadata
                FROM (
                  SELECT
                      pm3_calc_run_id,
                      state,
                      measure_calc_config
                    FROM (
                      SELECT
                          id AS pm3_calc_run_id,
                          jsonb_array_elements_text(metadata->'calculatorSettings'->'states') AS state
                        FROM pm3.pm3_calculator_metadata
                    ) AS t_states INNER JOIN (
                      SELECT
                          id AS pm3_calc_run_id,
                          jsonb_array_elements(metadata->'calculators') AS measure_calc_config
                        FROM pm3.pm3_calculator_metadata
                      UNION
                      SELECT
                          id AS pm3_calc_run_id,
                          jsonb_build_object(
                            'year',
                            (metadata->'calculatorSettings'->>'year')::INTEGER,
                            'measure',
                            'TMC_METADATA',
                            'isCanonical',
                            true
                          ) AS measure_calc_config
                        FROM pm3.pm3_calculator_metadata AS pcm
                        WHERE (
                          (pcm.metadata->'calculatorSettings'->'outputHPMSRequiredTmcMetadata')::BOOLEAN
                        )
                      UNION
                      SELECT
                          id AS pm3_calc_run_id,
                          jsonb_build_object(
                            'year',
                            (metadata->'calculatorSettings'->>'year')::INTEGER,
                            'measure',
                            'RIS_METADATA',
                            'isCanonical',
                            true
                          ) AS measure_calc_config
                        FROM pm3.pm3_calculator_metadata AS pcm
                        WHERE (
                          ( pcm.id = ANY( pcv.pm3calc_ids ) )
                          AND
                          ( (pcm.metadata->'calculatorSettings'->>'measures') LIKE '%_RIS%' )
                        )
                    ) AS t_metadata USING (pm3_calc_run_id)
                    WHERE (
                      ( pm3_calc_run_id = ANY( pcv.pm3calc_ids ) )
                      AND
                      ( measure_calc_config->>'measure' = ANY( pcv.available_measures ) )
                    )
                ) AS t0 LEFT OUTER JOIN LATERAL (
                  SELECT
                      data_provenance_metadata->(t0.state) AS data_provenance_metadata
                    FROM pm3.pm3_calculator_data_provenances AS pcdp
                    WHERE ( t0.pm3_calc_run_id = pcdp.id )
                ) AS t2 ON (true)
                GROUP BY state
            ) AS t1
          ) AS t ON (true)
;

COMMIT;
