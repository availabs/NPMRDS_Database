CREATE SCHEMA IF NOT EXISTS _transcom_admin;

CREATE TABLE IF NOT EXISTS _transcom_admin.transcom_events (
  event_id                    TEXT PRIMARY KEY,
  facility                    TEXT,
  event_type                  TEXT,
  summary_description         TEXT,
  state                       TEXT,
  county                      TEXT,
  city                        TEXT,
  last_update                 TIMESTAMP,
  manual_close_date           TIMESTAMP,
  event_duration              TEXT,
  start_date_time             TIMESTAMP,
  link_count                  TEXT, -- For all observed data, value was null
  to_city                     TEXT,
  secondary_marker            REAL,
  point_lat                   DOUBLE PRECISION,
  point_lon                   DOUBLE PRECISION,
  primary_marker              REAL,
  from_city                   TEXT,
  event_type_desc_id          SMALLINT,
  event_category              TEXT,
  reporting_org_id            SMALLINT,
  direction                   TEXT,
  eventstatus                 TEXT,
  year                        SMALLINT,
  data_source                 BOOLEAN,
  data_source_value           TEXT, -- For all observed data, value was null
  tmclist                     TEXT,
  recoverytime                TEXT, -- For all observed data, value was null
  recovery_time_in_formate    TEXT, -- For all observed data, value was null
  recoverydatetime            TEXT, -- For all observed data, value was null
  is_highway                  BOOLEAN,
  _created_timestamp          TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
  _modified_timestamp         TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
) WITH (fillfactor=100, autovacuum_enabled=false);


DROP TRIGGER IF EXISTS transcom_events_update_trigger
  ON _transcom_admin.transcom_events
;

CREATE TRIGGER transcom_events_update_trigger
 BEFORE
   UPDATE ON _transcom_admin.transcom_events
 FOR EACH ROW
   EXECUTE PROCEDURE _transcom_admin.update_modified_timestamp_trigger_fn()
;
-- ===== Indexes =====

CREATE INDEX IF NOT EXISTS transcom_events_year_idx
  ON _transcom_admin.transcom_events (date_part('year'::text, start_date_time))
;

-- point_geom will be in the VIEW
CREATE INDEX IF NOT EXISTS transcom_events_geom_idx
  ON _transcom_admin.transcom_events
    USING GIST (
      public.ST_SetSRID(
        public.ST_MakePoint(
          point_lon,
          point_lat
        ), 4326
      )
    )
;

CLUSTER _transcom_admin.transcom_events
  USING transcom_events_pkey
;
