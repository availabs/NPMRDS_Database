BEGIN;

CREATE TABLE IF NOT EXISTS public.here_realtime_traffic (
  tmc             TEXT NOT NULL,

  timestamp       TIMESTAMP WITHOUT TIME ZONE NOT NULL,

  travel_time     REAL NOT NULL,
  confidence      REAL,
  speed           REAL,
  jam_factor      REAL
) PARTITION BY RANGE (timestamp) ;

CREATE OR REPLACE VIEW public.here_realtime_npmrds
  AS
    SELECT
        tmc,
        timestamp::DATE AS date,
        (
          ( EXTRACT(HOUR FROM timestamp) * 12 )
          +
          FLOOR( EXTRACT(MINUTE FROM timestamp) / 5 )
        )::SMALLINT AS epoch,
        AVG(travel_time) AS travel_time_all_vehicles
      FROM public.here_realtime_traffic
      GROUP BY 1,2,3
;

COMMIT;
