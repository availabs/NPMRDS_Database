BEGIN;

CREATE TABLE "__STATE__".avg_speedlimits (
  LIKE public.avg_speedlimits EXCLUDING ALL
);

COMMIT;
