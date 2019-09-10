BEGIN;

DROP VIEW IF EXISTS pm3_admin_view;

CREATE OR REPLACE VIEW pm3_admin_view
AS
  SELECT
      pm3calc.id AS pm3_calculator_run_id,
      pm3meas.id AS pm3_measure_output_id,
      lat_states.states,
      pm3meas.metadata->>'year' AS year,
      pm3meas.metadata->>'measure' AS measure,
      (
        pm3meas.authoritative_start IS NOT NULL
        AND
        pm3meas.authoritative_end IS NULL
      ) AS is_authoritative
    FROM pm3_calculator_metadata AS pm3calc
      INNER JOIN pm3_measure_calculator_metadata AS pm3meas
        ON (pm3calc.id = pm3meas.pm3calc_id),
      LATERAL (
        SELECT string_agg(t.states::TEXT, ',') AS states
          FROM jsonb_array_elements_text(pm3calc.metadata->'calculatorSettings'->'states') AS t(states)
      ) lat_states
;

COMMIT;
