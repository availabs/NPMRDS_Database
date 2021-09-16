-- NOTE: By not using the tableColumns array to generate this statement,
--       we enforce consistency between the tableColumns array and the DB table schema.

INSERT INTO transcom.transcom_historical_events_v2
  SELECT DISTINCT ON (event_id)
        -- NOTE: * below ensures same column order as transcom_historical_events_v2 because
        --         __TMP_TABLE_NAME__ created as SELECT * FROM transcom_historical_events_v2
        *
      FROM __TMP_TABLE_NAME__
      ORDER BY creation DESC
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
        point_geom          =  EXCLUDED.point_geom
;
