BEGIN;

-- Archive mutated events
INSERT INTO transcom.transcom_historical_events_archive (
  event_id,
  event_type,
  facility,
  creation,
  open_time,
  close_time,
  duration,
  description,
  from_city,
  from_count,
  to_city,
  state,
  from_mile_marker,
  to_mile_marker,
  latitude,
  longitude,
  event_category,
  direction,
  recovery_time,
  recovery_date_time,
  duration_interval,
  point_geom,
  _created_timestamp,
  _modified_timestamp
)
  SELECT
      a.event_id,
      a.event_type,
      a.facility,
      a.creation,
      a.open_time,
      a.close_time,
      a.duration,
      a.description,
      a.from_city,
      a.from_count,
      a.to_city,
      a.state,
      a.from_mile_marker,
      a.to_mile_marker,
      a.latitude,
      a.longitude,
      a.event_category,
      a.direction,
      a.recovery_time,
      a.recovery_date_time,
      a.duration_interval,
      a.point_geom,
      a._created_timestamp,
      a._modified_timestamp
    FROM transcom.transcom_historical_events_v2 AS a
      INNER JOIN __TMP_TABLE_NAME__ AS b
        USING (event_id)
    WHERE (
      ( a.event_type <> b.event_type )
      OR
      ( a.facility <> b.facility )
      OR
      ( a.creation <> b.creation )
      OR
      ( a.open_time <> b.open_time )
      OR
      ( a.close_time <> b.close_time )
      OR
      ( a.duration <> b.duration )
      OR
      ( a.description <> b.description )
      OR
      ( a.from_city <> b.from_city )
      OR
      ( a.from_count <> b.from_count )
      OR
      ( a.to_city <> b.to_city )
      OR
      ( a.state <> b.state )
      OR
      ( a.from_mile_marker <> b.from_mile_marker )
      OR
      ( a.to_mile_marker <> b.to_mile_marker )
      OR
      ( a.latitude <> b.latitude )
      OR
      ( a.longitude <> b.longitude )
      OR
      ( a.event_category <> b.event_category )
      OR
      ( a.direction <> b.direction )
      OR
      ( a.recovery_time <> b.recovery_time )
      OR
      ( a.recovery_date_time <> b.recovery_date_time )
    )
;

INSERT INTO transcom.transcom_historical_events_v2 (
  event_id,
  event_type,
  facility,
  creation,
  open_time,
  close_time,
  duration,
  description,
  from_city,
  from_count,
  to_city,
  state,
  from_mile_marker,
  to_mile_marker,
  latitude,
  longitude,
  event_category,
  direction,
  recovery_time,
  recovery_date_time,
  duration_interval,
  point_geom
)
  SELECT DISTINCT ON (event_id)
        event_id,
        event_type,
        facility,
        creation,
        open_time,
        close_time,
        duration,
        description,
        from_city,
        from_count,
        to_city,
        state,
        from_mile_marker,
        to_mile_marker,
        latitude,
        longitude,
        event_category,
        direction,
        recovery_time,
        recovery_date_time,
        duration_interval,
        point_geom
      FROM __TMP_TABLE_NAME__
      ORDER BY event_id, open_time DESC
  ON CONFLICT ON CONSTRAINT transcom_historical_events_v2_pkey
    DO UPDATE
      SET
        event_id            =  EXCLUDED.event_id,
        event_type          =  EXCLUDED.event_type,
        facility            =  EXCLUDED.facility,
        creation            =  EXCLUDED.creation,
        open_time           =  EXCLUDED.open_time,
        close_time          =  EXCLUDED.close_time,
        duration            =  EXCLUDED.duration,
        description         =  EXCLUDED.description,
        from_city           =  EXCLUDED.from_city,
        from_count          =  EXCLUDED.from_count,
        to_city             =  EXCLUDED.to_city,
        state               =  EXCLUDED.state,
        from_mile_marker    =  EXCLUDED.from_mile_marker,
        to_mile_marker      =  EXCLUDED.to_mile_marker,
        latitude            =  EXCLUDED.latitude,
        longitude           =  EXCLUDED.longitude,
        event_category      =  EXCLUDED.event_category,
        direction           =  EXCLUDED.direction,
        recovery_time       =  EXCLUDED.recovery_time,
        recovery_date_time  =  EXCLUDED.recovery_date_time,
        duration_interval   =  EXCLUDED.duration_interval,
        point_geom          =  EXCLUDED.point_geom
;

COMMIT;
