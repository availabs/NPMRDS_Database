BEGIN;

CREATE OR REPLACE FUNCTION nprm1and2TimeBinFunc (date date, epoch integer) RETURNS integer
  AS 'SELECT CASE WHEN (EXTRACT(DOW FROM date) BETWEEN 1 AND 5) THEN 
              CASE WHEN (epoch BETWEEN (6*12) AND (10*12 - 1)) THEN 0
                WHEN (epoch BETWEEN (10*12) AND (16*12 - 1)) THEN 1
                ELSE 2
              END
            ELSE 3 END;'
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;

COMMIT;
