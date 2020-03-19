BEGIN;

-- TODO: Consolidate all dependent views DDL into a single
--         so we can DROP this view rather than REPLACE.
--         Currently, if columns need to change, manual
--         work would be required to re-CREATE the dependents. 
CREATE OR REPLACE VIEW pm3.pm3_measure_calculator_expanded_metadata
  AS
    SELECT
        a.id AS pm3calc_id,
        b.id AS pm3meacalc_id,
        b.metadata AS pm3meacalc_metadata,
        (a.metadata->>'timestamp')::TIMESTAMP AS calculator_run_timestamp,
        string_to_array(
          regexp_replace(
            jsonb_pretty(
              a.metadata->'calculatorSettings'->'states'
            ),
            '[\s\[\]"]',
            '',
            'g'
          ),
          ','
        ) AS states,
        (b.metadata->>'year')::INTEGER AS year,
        b.metadata->>'measure' AS measure,
        COALESCE((b.metadata->>'isCanonical')::BOOLEAN, false) AS is_canonical,
        b.authoritative_start,
        b.authoritative_end,
        (
          ( b.authoritative_start IS NOT NULL )
          AND
          ( b.authoritative_end IS NULL )
        ) AS is_authoritative
      FROM pm3.pm3_calculator_metadata AS a
        INNER JOIN pm3.pm3_measure_calculator_metadata AS b ON (a.id = b.pm3calc_id)
  ;

COMMIT;
