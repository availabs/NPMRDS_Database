BEGIN;

DROP VIEW IF EXISTS pm3.pm3_measure_calculator_output_with_measure_metadata_eav ;
DROP VIEW IF EXISTS pm3.pm3_measure_calculator_output_with_measure_metadata ;

CREATE VIEW pm3.pm3_measure_calculator_output_with_measure_metadata
  AS
    SELECT
        measure_metadata.*,
        measure_data.tmc,
        measure_data.measure_data
      FROM pm3.pm3_measure_calculator_expanded_metadata AS measure_metadata
        INNER JOIN pm3.pm3_measure_calculator_output AS measure_data USING (pm3meacalc_id)
  ;

CREATE VIEW pm3.pm3_measure_calculator_output_with_measure_metadata_eav
  AS
    SELECT
        pm3calc_id,
        pm3meacalc_id,
        pm3meacalc_metadata,
        calculator_run_timestamp,
        states,
        year,
        measure,
        is_canonical,
        authoritative_start,
        authoritative_end,
        is_authoritative,
        tmc,
        (d).key AS attribute,
        (d).value AS value
      FROM (
        SELECT
            pm3calc_id,
            pm3meacalc_id,
            pm3meacalc_metadata,
            calculator_run_timestamp,
            states,
            year,
            measure,
            is_canonical,
            authoritative_start,
            authoritative_end,
            is_authoritative,
            tmc,
            jsonb_each(measure_data) AS d
          FROM pm3.pm3_measure_calculator_output_with_measure_metadata
      ) AS t
  ;

COMMIT;
