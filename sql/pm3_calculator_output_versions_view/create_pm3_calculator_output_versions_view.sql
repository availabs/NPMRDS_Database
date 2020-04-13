BEGIN;

CREATE OR REPLACE VIEW pm3.pm3_calculator_output_versions_view
  AS
   SELECT
       version_id,
       tmc,
       measure,
       measure_data
     FROM pm3.pm3_calculation_versions_view AS pcvv
       INNER JOIN pm3.pm3_calculator_output AS pco
       ON (
         ( pco.pm3calc_id = ANY(pcvv.pm3calc_ids) )
         AND
         ( pco.measure = ANY(pcvv.available_measures) )
       )
;

COMMIT;
