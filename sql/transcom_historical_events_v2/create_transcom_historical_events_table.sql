BEGIN;

CREATE SCHEMA IF NOT EXISTS transcom;

CREATE TABLE IF NOT EXISTS transcom.transcom_historical_events_v2 (
  event_id                    TEXT PRIMARY KEY,
  event_state                 SMALLINT,
  event_msg                   TEXT,

  icon_file                   TEXT,
  event_type                  TEXT,
  facility                    TEXT,
  playback_text               TEXT,
  full_text                   TEXT,
  sort_order                  SMALLINT,
  state                       TEXT,
  county                      TEXT,
  event_impact                TEXT,
  relationship                TEXT,
  mile_marker                 TEXT,
  events_layer                TEXT,
  direction                   TEXT,
  notes                       TEXT,
  class_name                  TEXT,
  image_name                  TEXT,
  show_route_no               SMALLINT,
  route_no                    TEXT,
  overlap_events_with_length  TEXT,
  is_overlapping              SMALLINT,

  start_date_time             TIMESTAMP WITHOUT TIME ZONE,
  end_date                    TIMESTAMP WITHOUT TIME ZONE,
  last_update_date            TIMESTAMP WITHOUT TIME ZONE,

  category_name               TEXT,
  is_latest_event             BOOLEAN,
  is_highway                  BOOLEAN,

  to_state                    TEXT,
  to_city                     TEXT,
  to_facility                 TEXT,
  to_direction                TEXT,

  latitude                    DOUBLE PRECISION NOT NULL,
  longitude                   DOUBLE PRECISION NOT NULL,
  to_latitude                 DOUBLE PRECISION,
  to_longitude                DOUBLE PRECISION,

  event_category              TEXT,
  point_geom                  public.Geometry(Point, 4326),

  _created_timestamp          TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  _modified_timestamp         TIMESTAMP WITHOUT TIME ZONE NOT NULL
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
  ON transcom.transcom_historical_events_v2 (start_date_time, end_date)
;

CREATE INDEX IF NOT EXISTS transcom_historical_events_v2_year_idx
  ON transcom.transcom_historical_events_v2 (date_part('year'::text, start_date_time), end_date)
;

CREATE INDEX IF NOT EXISTS transcom_historical_events_v2_geom_index
  ON transcom.transcom_historical_events_v2
    USING GIST (point_geom)
;

CLUSTER transcom.transcom_historical_events_v2
  USING transcom_historical_events_v2_geom_index
;

COMMIT;
