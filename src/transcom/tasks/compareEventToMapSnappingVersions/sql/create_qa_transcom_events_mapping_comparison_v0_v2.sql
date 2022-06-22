BEGIN;

DROP MATERIALIZED VIEW IF EXISTS _transcom_admin.qa_transcom_events_mapping_comparison_v0_v2 ;

CREATE MATERIALIZED VIEW _transcom_admin.qa_transcom_events_mapping_comparison_v0_v2
  AS
    SELECT
        t.*,

        ST_Length(GEOGRAPHY(t.deviance_line)) AS deviance_meters,

        RANK() OVER (
          ORDER BY ST_Length(t.deviance_line) DESC
        ) AS deviance_rank
      FROM (
        SELECT
            event_id,
            year,

            a.transcom_event_point_geom,
            a.transcom_event_modified_timestamp,

            a.conflation_way_id AS old_conflation_way_id,
            a.conflation_node_id AS old_conflation_node_id,
            a.osm_fwd AS old_osm_fwd,

            a.transcom_event_point_geom AS old_transcom_event_point_geom,
            a.conflation_map_way_geom AS old_conflation_map_way_geom,
            a.conflation_map_node_geom AS old_conflation_map_node_geom,

            b.conflation_way_id AS new_conflation_way_id,
            b.conflation_node_id AS new_conflation_node_id,
            b.osm_fwd AS new_osm_fwd,

            b.transcom_event_point_geom AS new_transcom_event_point_geom,
            b.conflation_map_way_geom AS new_conflation_map_way_geom,
            b.conflation_map_node_geom AS new_conflation_map_node_geom,

            ST_Distance(
              GEOGRAPHY(a.conflation_map_node_geom),
              GEOGRAPHY(b.conflation_map_node_geom)
            ) AS conflation_map_node_difference_meters,

            ST_Distance(
              GEOGRAPHY(a.transcom_event_point_geom),
              GEOGRAPHY(a.conflation_map_node_geom)
            ) AS old_event_to_node_dist_meters,

            ST_Distance(
              GEOGRAPHY(b.transcom_event_point_geom),
              GEOGRAPHY(b.conflation_map_node_geom)
            ) AS new_event_to_node_dist_meters,

            ST_MakeLine(
              a.conflation_map_node_geom,
              b.conflation_map_node_geom
            ) AS deviance_line

          FROM _transcom_admin._transcom_events_onto_road_network_v0_0_0 AS a
            INNER JOIN _transcom_admin.transcom_events_onto_road_network_v0_0_2 AS b
              USING (event_id, year)
          WHERE ( year = 2022 )
      ) AS t
  ;

COMMIT;
