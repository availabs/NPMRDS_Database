BEGIN;

CREATE SCHEMA IF NOT EXISTS :"STATE";

DROP TABLE IF EXISTS :"STATE".tmc_average_day;

CREATE TABLE IF NOT EXISTS :"STATE".tmc_average_day (
  CHECK (state = :'STATE')
) INHERITS (public.tmc_average_day)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

INSERT INTO :"STATE".tmc_average_day (tmc, year, avg_day)
  SELECT
      tmc,
      year,
      ARRAY_AGG(tmc_average_day ORDER BY epoch) AS avg_day
    FROM (
      SELECT
          tmc,
          EXTRACT(YEAR from date) AS year,
          epoch,
          AVG(travel_time_all_vehicles) AS tmc_average_day
        --  FROM :"STATE".npmrds
        FROM npmrds
        GROUP BY tmc, year, epoch
    ) AS sub_data RIGHT OUTER JOIN (
      SELECT DISTINCT
          tmc,
          EXTRACT(YEAR from date) AS year,
          generate_series(0,287) AS epoch 
        --  FROM :"STATE".npmrds
        FROM npmrds
    ) AS sub_filler USING (tmc, year, epoch)
    GROUP BY tmc, year
;

COMMIT;
