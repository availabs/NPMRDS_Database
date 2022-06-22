-- For use in QGIS to visualize the diffence between versions

SELECT
		event_id,
		round(deviance_meters::NUMERIC * 0.000621371::NUMERIC, 2) as deviance_miles,
		deviance_line
	FROM _transcom_admin.qa_transcom_events_mapping_comparison_v0_v2
	-- WHERE ( transcom_event_modified_timestamp_difference < '6 hours' )
	ORDER BY deviance_rank
	LIMIT 250
;

select
	event_id,
	point_geom
  from _transcom_admin.transcom_events_expanded_view
  where (
    event_id in (
      SELECT
        event_id
      FROM _transcom_admin.qa_transcom_events_mapping_comparison_v0_v2
      ORDER BY deviance_rank
      LIMIT 250
    )
  )
;
