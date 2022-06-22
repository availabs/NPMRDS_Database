\timing

BEGIN ;

DROP MATERIALIZED VIEW IF EXISTS _transcom_admin._transcom_events_onto_conflation_map_v0_0_0 ;

CREATE MATERIALIZED VIEW _transcom_admin._transcom_events_onto_conflation_map_v0_0_0
  AS
    SELECT
        event_id,
        2022 AS year,
        c.node_id AS conflation_node_id,
        c.way_id AS conflation_way_id,
        c.osm_fwd,
        c.n,
        a._modified_timestamp
      FROM _transcom_admin.transcom_events_expanded_view AS a
        INNER JOIN _transcom_admin.transcom_event_administative_geographies AS b
          USING (event_id)
        LEFT JOIN LATERAL (
          SELECT
              UNNEST(y.node_ids) AS node_id,
              x.id AS way_id,
              x.osm_fwd,
              x.n
          FROM conflation.conflation_map_2022_v0_6_0 AS x
            INNER JOIN conflation.conflation_map_2022_ways_v0_6_0 AS y
              USING(id)
            LEFT OUTER JOIN ny.tmc_metadata_2022 AS z
              USING(tmc)
          WHERE COALESCE(z.direction, 'NONE') =
            CASE
              WHEN a.description LIKE '%northbound%' THEN 'N'
              WHEN a.description LIKE '%southbound%' THEN 'S'
              WHEN a.description LIKE '%eastbound%'  THEN 'E'
              WHEN a.description LIKE '%westbound%'  THEN 'W'
              ELSE 'NONE'
            END
          AND x.n < 7
          ORDER BY (a.point_geom <-> x.wkb_geometry) ASC
          LIMIT 1
        ) AS c ON TRUE
      WHERE (
        ( b.state_code = '36' )
        AND
        ( EXTRACT(YEAR FROM a.start_date_time) = 2022 )
        AND
        ( EXTRACT(YEAR FROM a.close_date) = 2022 )
      )
    ;

DROP VIEW _transcom_admin._transcom_events_onto_road_network_v0_0_0 ;

CREATE VIEW _transcom_admin._transcom_events_onto_road_network_v0_0_0
  AS
    SELECT
        a.event_id,
        a.year,

        a.conflation_way_id,
        a.conflation_node_id,

        CASE
          WHEN a.osm_fwd = 0 THEN -a.conflation_node_id
          ELSE a.conflation_node_id
        END AS signed_conflation_node_id,

        c.dir,
        a.n,
        c.osm,
        a.osm_fwd,
        c.ris,
        c.tmc,

        a._modified_timestamp AS transcom_event_modified_timestamp,

        b.point_geom    AS transcom_event_point_geom,
        c.wkb_geometry  AS conflation_map_way_geom,
        d.wkb_geometry  AS conflation_map_node_geom

      FROM _transcom_admin._transcom_events_onto_conflation_map_v0_0_0 AS a
        INNER JOIN _transcom_admin.transcom_events_expanded_view AS b
          USING (event_id)
        INNER JOIN conflation.conflation_map_2022_v0_6_0 AS c
          ON ( a.conflation_way_id = c.id )
        INNER JOIN conflation.conflation_map_2022_nodes_v0_6_0 AS d
          ON ( a.conflation_node_id = d.id )
;

DROP MATERIALIZED VIEW IF EXISTS _transcom_admin.qa_transcom_events_onto_road_network_v0_0_0 ;

CREATE MATERIALIZED VIEW _transcom_admin.qa_transcom_events_onto_road_network_v0_0_0
  AS
    SELECT
        event_id,
        year,

        ST_MakeLine(
          transcom_event_point_geom,
          conflation_map_node_geom
        ) AS event_to_node_pt_line,

        ST_Distance(
          GEOGRAPHY(transcom_event_point_geom),
          GEOGRAPHY(conflation_map_node_geom)
        ) AS event_to_node_dist_meters

      FROM _transcom_admin._transcom_events_onto_road_network_v0_0_0
;

COMMIT ;
