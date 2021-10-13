BEGIN;

CREATE TABLE IF NOT EXISTS public.here_realtime_traffic (
  tmc             TEXT NOT NULL,

  timestamp       TIMESTAMP WITHOUT TIME ZONE NOT NULL,

  travel_time     REAL NOT NULL,
  confidence      REAL,
  speed           REAL,
  jam_factor      REAL
) PARTITION BY RANGE (timestamp) ;

-- Because CREATE VIEW IF NOT EXISTS is not a thing,
--   and we do not want to replace here_realtime_traffic_current
--   if it already exists.
DO
$$
BEGIN

  IF NOT EXISTS (
      SELECT
          *
        FROM pg_views
        WHERE (
          ( schemaname = 'public' )
          AND
          ( viewname = 'here_realtime_traffic_current' )
        )
    ) THEN

      CREATE VIEW public.here_realtime_traffic_current
        AS
          SELECT
              *
            FROM public.here_realtime_traffic
      ;

  END IF;

END
$$;

COMMIT;
