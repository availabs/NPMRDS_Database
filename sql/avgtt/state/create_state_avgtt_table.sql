BEGIN;

CREATE SCHEMA IF NOT EXISTS :"STATE";

CREATE TABLE IF NOT EXISTS :"STATE".avgtt (
  CHECK (state = :'STATE')
) INHERITS (public.avgtt)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

DELETE FROM :"STATE".avgtt;

INSERT INTO :"STATE".avgtt (tmc, year, avg_day)
  SELECT
      tmc,
      year,
      jsonb_object_agg(epoch, avgtt)
    FROM (
      SELECT
          tmc,
          EXTRACT(YEAR FROM date) AS year,
          epoch,
          AVG(travel_time_all_vehicles) AS avgtt
        FROM :"STATE".npmrds
        GROUP BY tmc, year, epoch
    ) AS t
    GROUP BY tmc, year;
;

CLUSTER :"STATE".avgtt USING avgtt_pkey;

COMMIT;

ANALYZE :"STATE".avgtt;
