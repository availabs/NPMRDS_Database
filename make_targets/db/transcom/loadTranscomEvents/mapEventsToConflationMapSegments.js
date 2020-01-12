#!/usr/bin/env node

/* eslint no-console: 0, camelcase: 0 */

const mapEventsToTMCs = (client, conflationMapVersion) => {
  const sql = `
    BEGIN;

    DROP TABLE IF EXISTS tmp_buffered_event_pts;
    CREATE TEMPORARY TABLE tmp_buffered_event_pts
    AS
      SELECT
          event_id,
          point_geom,
          ST_Buffer(GEOGRAPHY(point_geom), 75) AS buffered_pt
        FROM transcom_events
        WHERE ( conflation_map_id IS NULL )
    ;

    CREATE INDEX tmp_buffered_event_pts_idx ON tmp_buffered_event_pts USING GIST (buffered_pt);
    CLUSTER tmp_buffered_event_pts USING tmp_buffered_event_pts_idx;
    ANALYZE tmp_buffered_event_pts;

    DROP TABLE IF EXISTS tmp_buffered_conflation_map_segments;
    CREATE TEMPORARY TABLE tmp_buffered_conflation_map_segments
    AS
      SELECT
          id AS conflation_map_segment,
          wkb_geometry,
          ST_Buffer(
            GEOGRAPHY(wkb_geometry),
            75
          ) AS buffered_conflation_map_segment
        FROM conflation_map_${conflationMapVersion}
    ;

    CREATE INDEX tmp_buffered_conflation_map_segments_idx ON tmp_buffered_conflation_map_segments USING GIST (buffered_conflation_map_segment);
    CLUSTER tmp_buffered_conflation_map_segments USING tmp_buffered_conflation_map_segments_idx;
    ANALYZE tmp_buffered_conflation_map_segments;

    DROP TABLE IF EXISTS tmp_events_to_conflation_map_segments;
    CREATE TEMPORARY TABLE tmp_events_to_conflation_map_segments
    AS
    SELECT
        event_id,
        MIN(shp.conflation_map_segment) AS conflation_map_segment
      FROM tmp_buffered_event_pts AS te
        INNER JOIN (
          SELECT
              event_id,
              MIN(ST_Distance(te.point_geom, shp.wkb_geometry))
                OVER (PARTITION BY event_id) AS min_dist
            FROM tmp_buffered_event_pts AS te
              JOIN tmp_buffered_conflation_map_segments AS shp
              ON (te.buffered_pt && shp.buffered_conflation_map_segment)
          ) AS sub_min_dists USING (event_id)
        INNER JOIN tmp_buffered_conflation_map_segments AS shp
          ON (te.buffered_pt && shp.buffered_conflation_map_segment)
        WHERE (ST_Distance(te.point_geom, shp.wkb_geometry) = sub_min_dists.min_dist)
        GROUP BY event_id
    ;

    UPDATE transcom_events
      SET conflation_map_segment = tmp_events_to_conflation_map_segments.conflation_map_segment 
        FROM tmp_events_to_conflation_map_segments
        WHERE (
          (transcom_events.event_id = tmp_events_to_conflation_map_segments.event_id)
          AND
          (transcom_events.conflation_map_segment is null)
        )
    ;

    COMMIT;
  `;

  return client.query(sql);
};
