BEGIN;

CREATE TABLE "__STATE__".avg_speedlimits (
  LIKE public.avg_speedlimits EXCLUDING ALL
);

ALTER TABLE "__STATE__".avg_speedlimits
  ALTER COLUMN state SET DEFAULT '__STATE__';

COMMIT;
