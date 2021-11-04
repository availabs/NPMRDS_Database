BEGIN;

CREATE TABLE IF NOT EXISTS public.here_realtime_traffic (
  tmc             TEXT NOT NULL,

  timestamp       TIMESTAMP WITHOUT TIME ZONE NOT NULL,

  travel_time     REAL NOT NULL,
  confidence      REAL,
  speed           REAL,
  jam_factor      REAL
) PARTITION BY RANGE (timestamp) ;

CREATE TABLE IF NOT EXISTS public.here_npmrds_schema (
  tmc                       TEXT NOT NULL,
  date                      DATE NOT NULL,
  epoch                     SMALLINT NOT NULL,
  travel_time_all_vehicles  REAL NOT NULL,

  staleness_minutes         INTEGER NOT NULL
) PARTITION BY RANGE (date) ;

-- Because CREATE VIEW IF NOT EXISTS is not a thing,
--   and we do not want to replace existing here_*_current views
DO
$$
BEGIN

  IF NOT EXISTS (
      SELECT
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

  IF NOT EXISTS (
      SELECT
        FROM pg_views
        WHERE (
          ( schemaname = 'public' )
          AND
          ( viewname = 'here_npmrds_schema_current' )
        )
    ) THEN

      CREATE VIEW public.here_npmrds_schema_current
        AS
          SELECT
              *
            FROM public.here_npmrds_schema
      ;

  END IF;

END
$$;

COMMIT;
