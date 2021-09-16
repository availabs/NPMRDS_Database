BEGIN;

CREATE SCHEMA IF NOT EXISTS transcom;

CREATE TABLE IF NOT EXISTS transcom.transcom_historical_events_v2 (
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

  point_geom              public.Geometry(Point,4326),

  _created_timestamp      TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  _modified_timestamp     TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

CREATE OR REPLACE FUNCTION transcom.transcom_historical_events_v2_trg_created_ts()
  RETURNS TRIGGER AS $$
    BEGIN
      NEW._created_timestamp = NOW();
      NEW._modified_timestamp = NOW();
      RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS transcom_historical_events_v2_created_timestamp
  ON transcom.transcom_historical_events_v2
;

CREATE TRIGGER transcom_historical_events_v2_created_timestamp
  BEFORE
    INSERT ON transcom.transcom_historical_events_v2
  FOR EACH ROW
    EXECUTE PROCEDURE transcom.transcom_historical_events_v2_trg_created_ts()
;

CREATE OR REPLACE FUNCTION transcom.transcom_historical_events_v2_trg_modified_ts()
  RETURNS TRIGGER AS $$
    BEGIN
      NEW._modified_timestamp = NOW();
      RETURN NEW;
    END;
$$ LANGUAGE plpgsql ;

DROP TRIGGER IF EXISTS transcom_historical_events_v2_modified_timestamp
  ON transcom.transcom_historical_events_v2
;

CREATE TRIGGER transcom_historical_events_v2_modified_timestamp
 BEFORE
   UPDATE ON transcom.transcom_historical_events_v2
 FOR EACH ROW
   EXECUTE PROCEDURE transcom.transcom_historical_events_v2_trg_modified_ts()
;

CREATE INDEX IF NOT EXISTS transcom_historical_events_v2_date_index
  ON transcom.transcom_historical_events_v2 (open_time, close_time)
;

CREATE INDEX IF NOT EXISTS transcom_historical_events_v2_year_idx
  ON transcom.transcom_historical_events_v2 (date_part('year'::text, open_time))
;

CREATE INDEX IF NOT EXISTS transcom_historical_events_v2_geom_index
  ON transcom.transcom_historical_events_v2
    USING GIST (point_geom)
;

CLUSTER transcom.transcom_historical_events_v2
  USING transcom_historical_events_v2_geom_index
;

COMMIT;
