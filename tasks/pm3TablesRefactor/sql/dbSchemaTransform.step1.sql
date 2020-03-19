BEGIN;

CREATE SCHEMA IF NOT EXISTS pm3;

ALTER TABLE pm3_calculator_metadata
  SET SCHEMA pm3 ;

CREATE VIEW public.pm3_calculator_metadata
  AS
    SELECT
        *
      FROM pm3.pm3_calculator_metadata
;

ALTER TABLE pm3_measure_calculator_metadata
  SET SCHEMA pm3 ;

CREATE VIEW public.pm3_measure_calculator_metadata
  AS
    SELECT
        *
      FROM pm3.pm3_measure_calculator_metadata
;

COMMIT;
