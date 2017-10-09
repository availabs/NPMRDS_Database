BEGIN;

CREATE OR REPLACE FUNCTION nprm3and4TimeBinFunc (epoch integer) RETURNS integer
  AS 'SELECT CASE 
               WHEN epoch BETWEEN 72  AND 83 THEN 0
               WHEN epoch BETWEEN 84  AND 95 THEN 1
               WHEN epoch BETWEEN 96  AND 108 THEN 2
               WHEN epoch BETWEEN 192 AND 203 THEN 3
               WHEN epoch BETWEEN 204 AND 215 THEN 4
               WHEN epoch BETWEEN 216 AND 227 THEN 5
             END AS time_period;'
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;

COMMIT;
