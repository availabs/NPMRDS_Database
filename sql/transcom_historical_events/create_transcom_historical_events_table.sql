BEGIN;

CREATE SCHEMA IF NOT EXISTS transcom;

CREATE TABLE IF NOT EXISTS transcom.transcom_historical_events (
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
  LIKE transcom.transcom_historical_events
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
  ON transcom.transcom_historical_events
;

CREATE TRIGGER transcom_historical_events_insert_trigger
  BEFORE
    INSERT ON transcom.transcom_historical_events
  FOR EACH ROW
    EXECUTE PROCEDURE transcom.transcom_historical_events_insert_fn()
;

CREATE OR REPLACE FUNCTION transcom.transcom_historical_events_update_fn()
  RETURNS TRIGGER AS $$
    BEGIN
      NEW._modified_timestamp = NOW();

      NEW.congestion_data =
        CASE
          WHEN (
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
        END;

      RETURN NEW;
    END;
$$ LANGUAGE plpgsql ;

DROP TRIGGER IF EXISTS transcom_historical_events_update_trigger
  ON transcom.transcom_historical_events
;

CREATE TRIGGER transcom_historical_events_update_trigger
 BEFORE
   UPDATE ON transcom.transcom_historical_events
 FOR EACH ROW
   EXECUTE PROCEDURE transcom.transcom_historical_events_update_fn()
;


-- ===== Indexes =====

CREATE INDEX IF NOT EXISTS transcom_historical_events_date_index
  ON transcom.transcom_historical_events (open_time, close_time)
;

CREATE INDEX IF NOT EXISTS transcom_historical_events_year_idx
  ON transcom.transcom_historical_events (date_part('year'::text, open_time))
;

CREATE INDEX IF NOT EXISTS transcom_historical_events_geom_index
  ON transcom.transcom_historical_events
    USING GIST (point_geom)
;

CLUSTER transcom.transcom_historical_events
  USING transcom_historical_events_geom_index
;

COMMIT;
