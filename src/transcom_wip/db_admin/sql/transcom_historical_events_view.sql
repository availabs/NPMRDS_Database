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
      b.event_class,
      c.display_in_incident_dashboard AS nysdot_display_in_incident_dashboard,
      c.general_category AS nysdot_general_category,
      c.sub_category AS nysdot_sub_category,
      c.detailed_category AS nysdot_detailed_category,
      c.waze_category AS nysdot_waze_category,
      c.display_if_lane_closure AS nysdot_display_if_lane_closure,
      c.duration_accurate AS nysdot_duration_accurate
    FROM transcom._transcom_historical_events AS a
      LEFT JOIN transcom.transcom_event_type_classifications AS b
        ON ( lower(a.event_type) = lower(b.event_type) )
      LEFT JOIN _transcom_admin.nysdot_transcom_event_classifications AS c
        ON ( lower(a.event_type) = lower(c.event_type) );
;
