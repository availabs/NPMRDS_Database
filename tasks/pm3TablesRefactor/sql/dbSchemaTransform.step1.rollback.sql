BEGIN;

CREATE SCHEMA IF NOT EXISTS pm3 ;

DROP VIEW public.pm3_calculator_metadata ;

ALTER TABLE pm3.pm3_calculator_metadata
  SET SCHEMA public ;

DROP VIEW public.pm3_measure_calculator_metadata ;

ALTER TABLE pm3.pm3_measure_calculator_metadata
  SET SCHEMA public ;

COMMIT;
