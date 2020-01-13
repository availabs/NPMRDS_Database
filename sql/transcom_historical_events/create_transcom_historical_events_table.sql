BEGIN;

CREATE SCHEMA IF NOT EXISTS transcom;

CREATE TABLE IF NOT EXISTS transcom.transcom_historical_events (
  event_id          VARCHAR PRIMARY KEY,
  event_type        VARCHAR,
  facility          VARCHAR,
  creation          TIMESTAMP WITHOUT TIME ZONE,
  open_time         TIMESTAMP WITHOUT TIME ZONE,
  close_time        TIMESTAMP WITHOUT TIME ZONE,
  duration          VARCHAR,
  description       VARCHAR,
  from_city         VARCHAR,
  from_count        VARCHAR,
  to_city           VARCHAR,
  state             VARCHAR,
  from_mile_marker  DOUBLE PRECISION,
  to_mile_marker    DOUBLE PRECISION,
  latitude          DOUBLE PRECISION,
  longitude         DOUBLE PRECISION,
  event_category    VARCHAR,
  point_geom        public.Geometry(Point,4326)
);

CREATE INDEX IF NOT EXISTS transcom_events_date_index
  ON transcom.transcom_historical_events
  USING btree (creation)
;

CREATE INDEX IF NOT EXISTS transcom_events_geom_index
  ON transcom.transcom_historical_events
  USING gist (point_geom)
;

CREATE INDEX IF NOT EXISTS transcom_events_year
  ON transcom.transcom_historical_events
  USING btree (date_part('year'::text, creation), event_category)
;

COMMIT;
