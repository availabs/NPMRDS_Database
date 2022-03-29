BEGIN;

CREATE SCHEMA IF NOT EXISTS transcom;

CREATE TABLE IF NOT EXISTS transcom._transcom_historical_events (
  event_id                TEXT PRIMARY KEY,
  event_type              TEXT,

  facility                TEXT,

  creation                TIMESTAMP WITHOUT TIME ZONE,
  open_time               TIMESTAMP WITHOUT TIME ZONE,
  close_time              TIMESTAMP WITHOUT TIME ZONE,
  duration                TEXT,

  state                   TEXT,
  from_count              TEXT,
  from_city               TEXT,
  to_city                 TEXT,

  description             TEXT,

  from_mile_marker        DOUBLE PRECISION,
  to_mile_marker          DOUBLE PRECISION,

  latitude                DOUBLE PRECISION,
  longitude               DOUBLE PRECISION,

  direction               TEXT,

  -- recovery_time field added in 2018.
  recovery_time           TEXT,
  recovery_date_time      TEXT,

  event_category          TEXT,

  -- Generated columns
  duration_interval       INTERVAL,

  point_geom              public.Geometry(Point,4326),

  congestion_data         JSONB,

  _created_timestamp      TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  _modified_timestamp     TIMESTAMP WITHOUT TIME ZONE NOT NULL
) WITH (fillfactor=100, autovacuum_enabled=false);


-- ===== Archive table for modified TranscomEvents =====

CREATE TABLE IF NOT EXISTS transcom.transcom_historical_events_archive (
  LIKE transcom._transcom_historical_events
) WITH (fillfactor=100, autovacuum_enabled=false);


-- ===== Created/Modified Triggers =====

CREATE OR REPLACE FUNCTION transcom.transcom_historical_events_insert_fn()
  RETURNS TRIGGER AS $$
    BEGIN
      NEW._created_timestamp = NOW();
      NEW._modified_timestamp = NOW();
      RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS transcom_historical_events_insert_trigger
  ON transcom._transcom_historical_events
;

CREATE TRIGGER transcom_historical_events_insert_trigger
  BEFORE
    INSERT ON transcom._transcom_historical_events
  FOR EACH ROW
    EXECUTE PROCEDURE transcom.transcom_historical_events_insert_fn()
;

CREATE OR REPLACE FUNCTION transcom.transcom_historical_events_update_fn()
  RETURNS TRIGGER AS $$
    BEGIN
      IF (
        ( COALESCE(OLD.event_type, 'OLD')                 <>  COALESCE(NEW.event_type, 'NEW') )
        OR
        ( COALESCE(OLD.facility, 'OLD')                   <>  COALESCE(NEW.facility, 'NEW') )
        OR
        (
          COALESCE(OLD.creation, (NOW() - '1 second'::INTERVAL))
          <>  COALESCE(NEW.creation, (NOW() - '1 second'::INTERVAL))
        )
        OR
        (
          COALESCE(OLD.open_time, (NOW() - '1 second'::INTERVAL))
          <>  COALESCE(NEW.open_time, (NOW() - '1 second'::INTERVAL))
        )
        OR
        (
          COALESCE(OLD.close_time, (NOW() - '1 second'::INTERVAL))
          <>  COALESCE(NEW.close_time, (NOW() - '1 second'::INTERVAL))
        )
        OR
        ( COALESCE(OLD.duration, 'OLD')                   <>  COALESCE(NEW.duration, 'NEW') )
        OR
        ( COALESCE(OLD.description, 'OLD')                <>  COALESCE(NEW.description, 'NEW') )
        OR
        ( COALESCE(OLD.from_city, 'OLD')                  <>  COALESCE(NEW.from_city, 'NEW') )
        OR
        ( COALESCE(OLD.from_count, 'OLD')                 <>  COALESCE(NEW.from_count, 'NEW') )
        OR
        ( COALESCE(OLD.to_city, 'OLD')                    <>  COALESCE(NEW.to_city, 'NEW') )
        OR
        ( COALESCE(OLD.state, 'OLD')                      <>  COALESCE(NEW.state, 'NEW') )
        OR
        ( COALESCE(OLD.from_mile_marker, -1.0)            <>  COALESCE(NEW.from_mile_marker, 1.0) )
        OR
        ( COALESCE(OLD.to_mile_marker, -1.0)              <>  COALESCE(NEW.to_mile_marker, 1.0) )
        OR
        ( COALESCE(OLD.latitude, -1.0)                    <>  COALESCE(NEW.latitude, 1.0) )
        OR
        ( COALESCE(OLD.longitude, -1.0)                   <>  COALESCE(NEW.longitude, 1.0) )
        OR
        ( COALESCE(OLD.event_category, 'OLD')             <>  COALESCE(NEW.event_category, 'NEW') )
        OR
        ( COALESCE(OLD.direction, 'OLD')                  <>  COALESCE(NEW.direction, 'NEW') )
        OR
        ( COALESCE(OLD.recovery_time, 'OLD')              <>  COALESCE(NEW.recovery_time, 'NEW') )
        OR
        ( COALESCE(OLD.recovery_date_time, 'OLD')         <>  COALESCE(NEW.recovery_date_time, 'NEW') )
        OR
        ( COALESCE(OLD.duration_interval, '-1 SECOND')    <>  COALESCE(NEW.duration_interval, '1 SECOND') )
      ) THEN
        -- Not updated through congestion_data calculation.
        NEW._modified_timestamp = NOW() ;
      END IF;

      NEW.congestion_data = COALESCE(
        NEW.congestion_data,
        CASE
          WHEN (
            (
              COALESCE(OLD.description, '')
              <> COALESCE(NEW.description, '')
            )
            OR
            (
              COALESCE(OLD.creation, '1900-01-01 00:00:00')
              <> COALESCE(NEW.creation, '1900-01-01 00:00:00')
            )
            OR
            (
              COALESCE(OLD.close_time, '1900-01-01 00:00:00')
              <> COALESCE(NEW.close_time, '1900-01-01 00:00:00')
            )
            OR
            (
              COALESCE(OLD.longitude, -1.0)
              <> COALESCE(NEW.longitude, -1.0)
            )
            OR
            (
              COALESCE(OLD.latitude, -1.0)
              <> COALESCE(NEW.latitude, -1.0)
            )
          ) THEN NULL
            ELSE OLD.congestion_data
        END
      );

      RETURN NEW;
    END;
$$ LANGUAGE plpgsql ;

DROP TRIGGER IF EXISTS transcom_historical_events_update_trigger
  ON transcom._transcom_historical_events
;

CREATE TRIGGER transcom_historical_events_update_trigger
 BEFORE
   UPDATE ON transcom._transcom_historical_events
 FOR EACH ROW
   EXECUTE PROCEDURE transcom.transcom_historical_events_update_fn()
;


-- ===== Indexes =====

CREATE INDEX IF NOT EXISTS transcom_historical_events_date_index
  ON transcom._transcom_historical_events (open_time, close_time)
;

CREATE INDEX IF NOT EXISTS transcom_historical_events_year_idx
  ON transcom._transcom_historical_events (date_part('year'::text, open_time))
;

CREATE INDEX IF NOT EXISTS transcom_historical_events_geom_index
  ON transcom._transcom_historical_events
    USING GIST (point_geom)
;

CLUSTER transcom._transcom_historical_events
  USING transcom_historical_events_geom_index
;

COMMIT;
