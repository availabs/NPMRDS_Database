BEGIN;

CREATE SCHEMA IF NOT EXISTS :"STATE";

CREATE TABLE IF NOT EXISTS :"STATE".avgtt (
  CHECK (state = :'STATE')
) INHERITS (public.avgtt)
;

CREATE TABLE IF NOT EXISTS :"STATE".avgtt_:YEAR (
  PRIMARY KEY (tmc),
  CHECK (state = :'STATE'),
  CHECK (year = :YEAR)
) INHERITS (:"STATE".avgtt)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

DELETE FROM :"STATE".avgtt_:YEAR;

INSERT INTO :"STATE".avgtt_:YEAR (tmc, year, avg_day, state)
  SELECT
      tmc,
      :YEAR AS year,
      jsonb_object_agg(epoch, avgtt),
      :'STATE' AS state
    FROM (
      SELECT
          tmc,
          epoch,
          AVG(travel_time_all_vehicles) AS avgtt
        FROM :"STATE".npmrds
        WHERE (
          ( date >= ('01/01/'||:'YEAR')::DATE )
          AND
          ( date < ('01/01/'||(:YEAR + 1)::TEXT)::DATE )
        )
        GROUP BY tmc, epoch
    ) AS t
    GROUP BY tmc
;

-- Because of the '_pkey' suffix
\set idx_name avgtt_:YEAR'_pkey'

CLUSTER :"STATE".avgtt_:YEAR USING :idx_name;

COMMIT;

ANALYZE :"STATE".avgtt;
ANALYZE :"STATE".avgtt_:YEAR;
