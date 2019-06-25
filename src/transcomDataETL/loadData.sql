-- NOTE: This script requires a table named tmp_new_transcom_events
--       During ETL, that temporary table is created and loaded by ./loadData.
--       ./loadData should call this file. It is not intended to stand-alone.

UPDATE tmp_new_transcom_events
  SET point_geom = ST_SetSRID(
    ST_MakePoint(
      longitude,
      latitude
    ),
    4326
  )
;

CREATE TEMPORARY TABLE tmp_buffered_event_pts
  ON COMMIT DROP
  AS
    SELECT
        event_id,
        point_geom,
        ST_Buffer(
          GEOGRAPHY(point_geom),
          75
        ) AS buffered_pt
      FROM tmp_new_transcom_events
;

CREATE INDEX tmp_buffered_event_pts_idx
  ON tmp_buffered_event_pts USING GIST (buffered_pt);

CLUSTER tmp_buffered_event_pts USING tmp_buffered_event_pts_idx;
ANALYZE tmp_buffered_event_pts;

CREATE TEMPORARY TABLE tmp_buffered_tmcs
  ON COMMIT DROP
  AS
    SELECT
        tmc,
        wkb_geometry,
        ST_Buffer(
          GEOGRAPHY(wkb_geometry),
          75
        ) AS buffered_tmc
      FROM npmrds_shapefile_:YEAR
;

CREATE INDEX tmp_buffered_tmcs_idx
  ON tmp_buffered_tmcs USING GIST (buffered_tmc)
;

CLUSTER tmp_buffered_tmcs USING tmp_buffered_tmcs_idx;
ANALYZE tmp_buffered_tmcs;

CREATE TEMPORARY TABLE tmp_events_to_tmcs
  ON COMMIT DROP
  AS
    SELECT
          *
        FROM (
          SELECT
              event_id,
              tmc,
              RANK() OVER (
                PARTITION BY event_id
                ORDER BY
                  ST_Distance(
                    te.point_geom,
                    shp.wkb_geometry
                  ),
                  tmc
              ) AS closeness_rank
            FROM tmp_buffered_event_pts AS te
              JOIN tmp_buffered_tmcs AS shp
              ON (
                te.buffered_pt && shp.buffered_tmc
              )
        ) AS sub_closeness_rankings
      WHERE closeness_rank = 1
;

INSERT INTO transcom.transcom_events
  SELECT DISTINCT ON (event_id)
      t0.event_id,
      t0.event_type,
      t0.facility,
      t0.creation,
      t0.open_time,
      t0.close_time,
      t0.duration,
      t0.description,
      t0.from_city,
      t0.from_count,
      t0.to_city,
      t0.state,
      t0.from_mile_marker,
      t0.to_mile_marker,
      t0.latitude,
      t0.longitude,
      t0.event_category,
      t0.point_geom,
      t1.tmc
    FROM tmp_new_transcom_events AS t0
      INNER JOIN tmp_events_to_tmcs AS t1 USING (event_id)
    ON CONFLICT ON CONSTRAINT transcom_events_pkey
      DO UPDATE SET
        event_id          =  EXCLUDED.event_id,
        event_type        =  EXCLUDED.event_type,
        facility          =  EXCLUDED.facility,
        creation          =  EXCLUDED.creation,
        open_time         =  EXCLUDED.open_time,
        close_time        =  EXCLUDED.close_time,
        duration          =  EXCLUDED.duration,
        description       =  EXCLUDED.description,
        from_city         =  EXCLUDED.from_city,
        from_count        =  EXCLUDED.from_count,
        to_city           =  EXCLUDED.to_city,
        state             =  EXCLUDED.state,
        from_mile_marker  =  EXCLUDED.from_mile_marker,
        to_mile_marker    =  EXCLUDED.to_mile_marker,
        latitude          =  EXCLUDED.latitude,
        longitude         =  EXCLUDED.longitude,
        event_category    =  EXCLUDED.event_category,
        point_geom        =  EXCLUDED.point_geom,
        tmc               =  EXCLUDED.tmc
;
