DROP TABLE IF EXISTS transcom.transcom_events_osm_mappings ;

CREATE TABLE IF NOT EXISTS transcom.transcom_events_osm_mappings (
  event_id    TEXT,
  year        SMALLINT,
  node_id     BIGINT,
  way_id      BIGINT,

  _created_timestamp  TIMESTAMP NOT NULL,
  _modified_timestamp TIMESTAMP NOT NULL,

  PRIMARY KEY (event_id, year)
) ;
