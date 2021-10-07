BEGIN;

DROP VIEW IF EXISTS public.here_realtime_npmrds;
CREATE OR REPLACE VIEW public.here_realtime_npmrds
  AS
    SELECT
        tmc,
        MIN(timestamp) OVER (PARTITION BY tmc, date, epoch) AS timestamp,
        date,
        epoch,
        ROUND(
          (
            SUM (weighted_tt) OVER (PARTITION BY tmc, date, epoch)
            /
            SUM (weight) OVER (PARTITION BY tmc, date, epoch)
          )::NUMERIC, 1
        ) AS travel_time_all_vehicles
      FROM (
        SELECT
            tmc,
            timestamp,
            timestamp::DATE AS date,
            (
              ( EXTRACT(HOUR FROM timestamp) * 12 )
              +
              FLOOR( EXTRACT(MINUTE FROM timestamp) / 5 )
            )::SMALLINT AS epoch,
            (
              travel_time
              * CASE
                  WHEN (( EXTRACT(MINUTE FROM timestamp)::INTEGER % 10 ) = 4 )
                    THEN 0.5
                  ELSE 1
                END
            ) AS weighted_tt,
            CASE
              WHEN (( EXTRACT(MINUTE FROM timestamp)::INTEGER % 10 ) = 4 )
                THEN 0.5
              ELSE 1
            END AS weight
          FROM public.here_realtime_traffic
      ) AS t
;

COMMIT;
