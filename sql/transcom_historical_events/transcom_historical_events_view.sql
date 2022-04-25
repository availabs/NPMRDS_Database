CREATE OR REPLACE VIEW transcom.transcom_historical_events
  AS
    SELECT a.event_id,
      a.event_type,
      a.facility,
      a.creation,
      a.open_time,
      a.close_time,
      a.duration,
      a.state,
      a.from_count,
      a.from_city,
      a.to_city,
      a.description,
      a.from_mile_marker,
      a.to_mile_marker,
      a.latitude,
      a.longitude,
      a.direction,
      a.recovery_time,
      a.recovery_date_time,
      a.event_category,
      a.duration_interval,
      a.point_geom,
      a.congestion_data,
      a._created_timestamp,
      a._modified_timestamp,
      b.event_class
    FROM transcom._transcom_historical_events a
      LEFT JOIN transcom.transcom_event_type_classifications b
        ON ( lower(a.event_type) = lower(b.event_type) );
