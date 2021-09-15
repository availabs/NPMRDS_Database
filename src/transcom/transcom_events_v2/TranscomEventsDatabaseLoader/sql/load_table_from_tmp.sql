-- NOTE: By not using the tableColumns array to generate this statement,
--       we enforce consistency between the tableColumns array and the DB table schema.

INSERT INTO transcom.transcom_historical_events_v2
  SELECT DISTINCT ON (event_id)
        -- NOTE: * below ensures same column order as transcom_historical_events_v2 because
        --         __TMP_TABLE_NAME__ created as SELECT * FROM transcom_historical_events_v2
        *
      FROM __TMP_TABLE_NAME__
  ON CONFLICT ON CONSTRAINT transcom_historical_events_v2_pkey
    DO UPDATE
      SET
        event_id                    =  EXCLUDED.event_id,
        event_state                 =  EXCLUDED.event_state,
        icon_file                   =  EXCLUDED.icon_file,
        event_type                  =  EXCLUDED.event_type,
        facility                    =  EXCLUDED.facility,
        playback_text               =  EXCLUDED.playback_text,
        latitude                    =  EXCLUDED.latitude,
        longitude                   =  EXCLUDED.longitude,
        full_text                   =  EXCLUDED.full_text,
        sort_order                  =  EXCLUDED.sort_order,
        state                       =  EXCLUDED.state,
        county                      =  EXCLUDED.county,
        event_impact                =  EXCLUDED.event_impact,
        relationship                =  EXCLUDED.relationship,
        mile_marker                 =  EXCLUDED.mile_marker,
        events_layer                =  EXCLUDED.events_layer,
        last_update_date            =  EXCLUDED.last_update_date,
        direction                   =  EXCLUDED.direction,
        notes                       =  EXCLUDED.notes,
        class_name                  =  EXCLUDED.class_name,
        image_name                  =  EXCLUDED.image_name,
        show_route_no               =  EXCLUDED.show_route_no,
        route_no                    =  EXCLUDED.route_no,
        overlap_events_with_length  =  EXCLUDED.overlap_events_with_length,
        end_date                    =  EXCLUDED.end_date,
        start_date_time             =  EXCLUDED.start_date_time,
        category_name               =  EXCLUDED.category_name,
        is_latest_event             =  EXCLUDED.is_latest_event,
        is_highway                  =  EXCLUDED.is_highway,
        to_latitude                 =  EXCLUDED.to_latitude,
        to_longitude                =  EXCLUDED.to_longitude,
        event_msg                   =  EXCLUDED.event_msg,
        to_state                    =  EXCLUDED.to_state,
        to_city                     =  EXCLUDED.to_city,
        to_facility                 =  EXCLUDED.to_facility,
        to_direction                =  EXCLUDED.to_direction,
        is_overlapping              =  EXCLUDED.is_overlapping,
        event_category              =  EXCLUDED.event_category,
        point_geom                  =  EXCLUDED.point_geom
;
