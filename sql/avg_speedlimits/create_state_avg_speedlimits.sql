CREATE TABLE :"STATE".avg_speedlimits (
  LIKE public.avg_speedlimits INCLUDING ALL
);

ALTER TABLE :"STATE".avg_speedlimits
  ALTER COLUMN state SET DEFAULT :'STATE';
